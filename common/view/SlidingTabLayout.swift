//  /*
//  * Copyright (C) 2013 The Android Open Source Project
//  *
//  * Licensed under the Apache License, Version 2.0 (the "License");
//  * you may not use this file except in compliance with the License.
//  * You may obtain a copy of the License at
//  *
//  *	  http://www.apache.org/licenses/LICENSE-2.0
//  *
//  * Unless required by applicable law or agreed to in writing, software
//  * distributed under the License is distributed on an "AS IS" BASIS,
//  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  * See the License for the specific language governing permissions and
//  * limitations under the License.
//  */
import android.content
import android.graphics
import android.os
import android.support.v4.view
import android.util
import android.view
import android.widget

//  namespace com.example.android.common.view
//  /**
//  * To be used with ViewPager to provide a tab indicator component which give constant feedback as to
//  * the user's scroll progress.
//  * <p>
//  * To use the component, simply add it to your view hierarchy. Then in your
//  * {@link android.app.Activity} or {@link android.support.v4.app.Fragment} call
//  * {@link #setViewPager(ViewPager)} providing it the ViewPager this layout is being used for.
//  * <p>
//  * The colors can be customized in two ways. The first and simplest is to provide an array of colors
//  * via {@link #setSelectedIndicatorColors(int...)} and {@link #setDividerColors(int...)}. The
//  * alternative is via the {@link TabColorizer} interface which provides you complete control over
//  * which color is used for any individual position.
//  * <p>
//  * The views used as tabs can be customized by calling {@link #setCustomTabView(int, int)},
//  * providing the layout ID of your custom layout.
//  */
class SlidingTabLayout: HorizontalScrollView {
	//  /**
	//  * Allows complete control over the colors drawn in the tab layout. Set with
	//  * {@link #setCustomTabColorizer(TabColorizer)}.
	//  */
	protocol TabColorizer {
		func getIndicatorColor(_ position: Int32) -> Int32
		func getDividerColor(_ position: Int32) -> Int32
	}

	static let TITLE_OFFSET_DIPS: Int32 = 24
	static let TAB_VIEW_PADDING_DIPS: Int32 = 16
	static let TAB_VIEW_TEXT_SIZE_SP: Int32 = 12
	var mTitleOffset: Int32
	var mTabViewLayoutId: Int32 = 0
	var mTabViewTextViewId: Int32 = 0
	var mViewPager: ViewPager!
	var mViewPagerPageChangeListener: ViewPager.OnPageChangeListener!
	var mTabStrip: SlidingTabStrip!

	convenience init(_ context: Context!) {
		self.init(context, nil)
	}

	convenience init(_ context: Context!, _ attrs: AttributeSet!) {
		self.init(context, attrs, 0)
	}

	init(_ context: Context!, _ attrs: AttributeSet!, _ defStyle: Int32) {
		super.init(context, attrs, defStyle)
		// Disable the Scroll Bar
		setHorizontalScrollBarEnabled(false)
		// Make sure that the Tab Strips fills this View
		setFillViewport(true)
		mTitleOffset = (TITLE_OFFSET_DIPS * Int32(getResources().getDisplayMetrics().density))
		mTabStrip = SlidingTabStrip(context)
		addView(mTabStrip, LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT)
	}

	func setCustomTabColorizer(_ tabColorizer: TabColorizer!) {
		mTabStrip.setCustomTabColorizer(tabColorizer)
	}

	func setSelectedIndicatorColors(_ colors: Int32[]!) {
		mTabStrip.setSelectedIndicatorColors(colors)
	}

	func setDividerColors(_ colors: Int32[]!) {
		mTabStrip.setDividerColors(colors)
	}

	func setOnPageChangeListener(_ listener: ViewPager.OnPageChangeListener!) {
		mViewPagerPageChangeListener = listener
	}

	func setCustomTabView(_ layoutResId: Int32, _ textViewId: Int32) {
		mTabViewLayoutId = layoutResId
		mTabViewTextViewId = textViewId
	}

	func setViewPager(_ viewPager: ViewPager!) {
		mTabStrip.removeAllViews()
		mViewPager = viewPager
		if viewPager != nil {
			viewPager.setOnPageChangeListener(InternalViewPagerListener(self))
			populateTabStrip()
		}
	}

	func createDefaultTabView(_ context: Context!) -> TextView! {
		var textView: TextView! = TextView(context)
		textView.setGravity(Gravity.CENTER)
		textView.setTextSize(TypedValue.COMPLEX_UNIT_SP, TAB_VIEW_TEXT_SIZE_SP)
		textView.setTypeface(Typeface.DEFAULT_BOLD)
		if Build.VERSION.SDK_INT >= Build.VERSION_CODES.HONEYCOMB {
			// If we're running on Honeycomb or newer, then we can use the Theme's
			// selectableItemBackground to ensure that the View has a pressed state
			var outValue: TypedValue! = TypedValue()
			getContext().getTheme().resolveAttribute(android.R.attr.selectableItemBackground, outValue, true)
			textView.setBackgroundResource(outValue.resourceId)
		}
		if Build.VERSION.SDK_INT >= Build.VERSION_CODES.ICE_CREAM_SANDWICH {
			// If we're running on ICS or newer, enable all-caps to match the Action Bar tab style
			textView.setAllCaps(true)
		}
		var padding: Int32 = (TAB_VIEW_PADDING_DIPS * Int32(getResources().getDisplayMetrics().density)) 
		textView.setPadding(padding, padding, padding, padding)
		return textView
	}

	func populateTabStrip() {
		var adapter: PagerAdapter! = mViewPager.getAdapter()
		var tabClickListener: View.OnClickListener! = TabClickListener(self)
		for i in 0..<adapter.getCount() {
			var tabView: View! = nil
			var tabTitleView: TextView! = nil
			if mTabViewLayoutId != 0 {
				// If there is a custom tab view layout id set, try and inflate it
				tabView = LayoutInflater.from(getContext()).inflate(mTabViewLayoutId, mTabStrip, false)
				tabTitleView = tabView.findViewById(mTabViewTextViewId) as? TextView
			}
			if tabView == nil {
				tabView = createDefaultTabView(getContext())
			}
			if (tabTitleView == nil) && tabView is TextView {
				tabTitleView = tabView as? TextView
			}
			tabTitleView.setText(adapter.getPageTitle(i))
			tabView.setOnClickListener(tabClickListener)
			mTabStrip.addView(tabView)
		}
	}

	override func onAttachedToWindow() {
		super.onAttachedToWindow()
		if mViewPager != nil {
			scrollToTab(mViewPager.getCurrentItem(), 0)
		}
	}

	func scrollToTab(_ tabIndex: Int32, _ positionOffset: Int32) {
		var tabStripChildCount: Int32 = mTabStrip.getChildCount()
		if ((tabStripChildCount == 0) | (tabIndex < 0)) | (tabIndex >= tabStripChildCount) {
			return
		}
		var selectedChild: View! = mTabStrip.getChildAt(tabIndex)
		if selectedChild != nil {
			var targetScrollX: Int32 = selectedChild.getLeft() + positionOffset
			if (tabIndex > 0) | (positionOffset > 0) {
				// If we're not at the first child and are mid-scroll, make sure we obey the offset
				targetScrollX -= mTitleOffset
			}
			scrollTo(targetScrollX, 0)
		}
	}

	class InternalViewPagerListener: ViewPager.OnPageChangeListener {
		var mScrollState: Int32 = 0
		var mParent: SlidingTabLayout!

		init(_ parent: SlidingTabLayout!) {
			mParent = parent
		}

		func onPageScrolled(_ position: Int32, _ positionOffset: Float, _ positionOffsetPixels: Int32) {
			var tabStripChildCount: Int32 = mParent.mTabStrip.getChildCount()
			if ((tabStripChildCount == 0) | (position < 0)) | (position >= tabStripChildCount) {
				return
			}
			mParent.mTabStrip.onViewPagerPageChanged(position, positionOffset)
			var selectedTitle: View! = mParent.mTabStrip.getChildAt(position)
			var extraOffset: Int32 = 0
			if selectedTitle != nil { extraOffset = Int(positionOffset) * selectedTitle.getWidth() }
			mParent.scrollToTab(position, extraOffset)
			if mParent.mViewPagerPageChangeListener != nil {
				mParent.mViewPagerPageChangeListener.onPageScrolled(position, positionOffset, positionOffsetPixels)
			}
		}

		func onPageScrollStateChanged(_ state: Int32) {
			mScrollState = state
			if mParent.mViewPagerPageChangeListener != nil {
				mParent.mViewPagerPageChangeListener.onPageScrollStateChanged(state)
			}
		}

		func onPageSelected(_ position: Int32) {
			if mScrollState == ViewPager.SCROLL_STATE_IDLE {
				mParent.mTabStrip.onViewPagerPageChanged(position, 0.0)
				mParent.scrollToTab(position, 0)
			}
			if mParent.mViewPagerPageChangeListener != nil {
				mParent.mViewPagerPageChangeListener.onPageSelected(position)
			}
		}
	}

	class TabClickListener: View.OnClickListener {
		var mParent: SlidingTabLayout!

		init(_ parent: SlidingTabLayout!) {
			mParent = parent
		}

		func onClick(_ v: View!) {
			for i in 0..<mParent.mTabStrip.getChildCount() {
				if v == mParent.mTabStrip.getChildAt(i) {
					mParent.mViewPager.setCurrentItem(i)
					return
				}
			}
		}
	}

}
