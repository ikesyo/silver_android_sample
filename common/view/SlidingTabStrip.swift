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
import android
import android.content
import android.graphics
import android.util
import android.view
import android.widget

//  namespace com.example.android.common.view
class SlidingTabStrip: LinearLayout {
	static let DEFAULT_BOTTOM_BORDER_THICKNESS_DIPS: Int32 = 2
	static let DEFAULT_BOTTOM_BORDER_COLOR_ALPHA: Int8 = 38
	static let SELECTED_INDICATOR_THICKNESS_DIPS: Int32 = 8
	static let DEFAULT_SELECTED_INDICATOR_COLOR: Int64 = 4281578981
	static let DEFAULT_DIVIDER_THICKNESS_DIPS: Int32 = 1
	static let DEFAULT_DIVIDER_COLOR_ALPHA: Int8 = 32
	static let DEFAULT_DIVIDER_HEIGHT: Float = 0.5
	var mBottomBorderThickness: Int32
	var mBottomBorderPaint: Paint!
	var mSelectedIndicatorThickness: Int32
	var mSelectedIndicatorPaint: Paint!
	var mDefaultBottomBorderColor: Int32
	var mDividerPaint: Paint!
	var mDividerHeight: Float
	var mSelectedPosition: Int32 = 0
	var mSelectionOffset: Float = 0
	var mCustomTabColorizer: SlidingTabLayout.TabColorizer!
	var mDefaultTabColorizer: SimpleTabColorizer!

	convenience init(_ context: Context!) {
		self.init(context, nil)
	}

	init(_ context: Context!, _ attrs: AttributeSet!) {
		super.init(context, attrs)
		setWillNotDraw(false)
		var density: Int32 = Int32(getResources().getDisplayMetrics().density)
		var outValue: TypedValue! = TypedValue()
		context.getTheme().resolveAttribute(android.R.attr.colorForeground, outValue, true)
		var themeForegroundColor: Int32 = outValue.data
		mDefaultBottomBorderColor = setColorAlpha(themeForegroundColor, DEFAULT_BOTTOM_BORDER_COLOR_ALPHA)
		mDefaultTabColorizer = SimpleTabColorizer()
		mDefaultTabColorizer.setIndicatorColors([DEFAULT_SELECTED_INDICATOR_COLOR])
		mDefaultTabColorizer.setDividerColors([setColorAlpha(themeForegroundColor, DEFAULT_DIVIDER_COLOR_ALPHA)])
		mBottomBorderThickness = DEFAULT_BOTTOM_BORDER_THICKNESS_DIPS * density 
		mBottomBorderPaint = Paint()
		mBottomBorderPaint.setColor(mDefaultBottomBorderColor)
		mSelectedIndicatorThickness = SELECTED_INDICATOR_THICKNESS_DIPS * density 
		mSelectedIndicatorPaint = Paint()
		mDividerHeight = DEFAULT_DIVIDER_HEIGHT
		mDividerPaint = Paint()
		mDividerPaint.setStrokeWidth(DEFAULT_DIVIDER_THICKNESS_DIPS * density)
	}

	func setCustomTabColorizer(_ customTabColorizer: SlidingTabLayout.TabColorizer!) {
		mCustomTabColorizer = customTabColorizer
		invalidate()
	}

	func setSelectedIndicatorColors(_ colors: Int32[]!) {
		// Make sure that the custom colorizer is removed
		mCustomTabColorizer = nil
		mDefaultTabColorizer.setIndicatorColors(colors)
		invalidate()
	}

	func setDividerColors(_ colors: Int32[]!) {
		// Make sure that the custom colorizer is removed
		mCustomTabColorizer = nil
		mDefaultTabColorizer.setDividerColors(colors)
		invalidate()
	}

	func onViewPagerPageChanged(_ position: Int32, _ positionOffset: Float) {
		mSelectedPosition = position
		mSelectionOffset = positionOffset
		invalidate()
	}

	override func onDraw(_ canvas: Canvas!) {
		var height: Int32 = getHeight()
		var childCount: Int32 = getChildCount()
		var dividerHeightPx: Int32 = Int32(Math.min(Math.max(0.0, mDividerHeight), 1.0)) * height 
		var tabColorizer: SlidingTabLayout.TabColorizer! = mCustomTabColorizer != nil ? mCustomTabColorizer : mDefaultTabColorizer
		// Thick colored underline below the current selection
		if childCount > 0 {
			var selectedTitle: View! = getChildAt(mSelectedPosition)
			var `left`: Int32 = selectedTitle.getLeft()
			var `right`: Int32 = selectedTitle.getRight()
			var color: Int32 = tabColorizer.getIndicatorColor(mSelectedPosition)
			if (mSelectionOffset > 0.0) & (mSelectedPosition < (getChildCount() - 1)) {
				var nextColor: Int32 = tabColorizer.getIndicatorColor(mSelectedPosition + 1)
				if color != nextColor {
					color = blendColors(nextColor, color, mSelectionOffset)
				}
				// Draw the selection partway between the tabs
				var nextTitle: View! = getChildAt(mSelectedPosition + 1)
				left = ((Int(mSelectionOffset) * nextTitle.getLeft()) + ((1 - Int(mSelectionOffset)) * `left`)) 
				right = ((Int(mSelectionOffset) * nextTitle.getRight()) + ((1 - Int(mSelectionOffset)) * `right`)) 
			}
			mSelectedIndicatorPaint.setColor(color)
			canvas.drawRect(`left`, height - mSelectedIndicatorThickness, `right`, height, mSelectedIndicatorPaint)
		}
		// Thin underline along the entire bottom edge
		canvas.drawRect(0, height - mBottomBorderThickness, getWidth(), height, mBottomBorderPaint)
		// Vertical separators between the titles
		var separatorTop: Int32 = (height - dividerHeightPx) / 2
		for i in 0..<childCount {
			var child: View! = getChildAt(i)
			mDividerPaint.setColor(tabColorizer.getDividerColor(i))
			canvas.drawLine(child.getRight(), separatorTop, child.getRight(), separatorTop + dividerHeightPx, mDividerPaint)
		}
	}

	class func setColorAlpha(_ color: Int32, _ alpha: Int8) -> Int32 {
		return Color.argb(alpha, Color.red(color), Color.green(color), Color.blue(color))
	}

	class func blendColors(_ color1: Int32, _ color2: Int32, _ ratio: Float) -> Int32 {
		var inverseRation: Float = 1.0 - ratio
		var r: Float = (Color.red(color1) * ratio) + (Color.red(color2) * inverseRation)
		var g: Float = (Color.green(color1) * ratio) + (Color.green(color2) * inverseRation)
		var b: Float = (Color.blue(color1) * ratio) + (Color.blue(color2) * inverseRation)
		return Color.rgb(Int(r), Int(g), Int(b))
	}

	class SimpleTabColorizer: SlidingTabLayout.TabColorizer {
		var mIndicatorColors: Int32[]!
		var mDividerColors: Int32[]!

		func getIndicatorColor(_ position: Int32) -> Int32 {
			return mIndicatorColors[position % mIndicatorColors.length]
		}

		func getDividerColor(_ position: Int32) -> Int32 {
			return mDividerColors[position % mDividerColors.length]
		}

		func setIndicatorColors(_ colors: Int32[]!) {
			mIndicatorColors = colors
		}

		func setDividerColors(_ colors: Int32[]!) {
			mDividerColors = colors
		}
	}

}
