//  /*
//  * Copyright 2014 The Android Open Source Project
//  *
//  * Licensed under the Apache License, Version 2.0 (the "License");
//  * you may not use this file except in compliance with the License.
//  * You may obtain a copy of the License at
//  *
//  *	   http://www.apache.org/licenses/LICENSE-2.0
//  *
//  * Unless required by applicable law or agreed to in writing, software
//  * distributed under the License is distributed on an "AS IS" BASIS,
//  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  * See the License for the specific language governing permissions and
//  * limitations under the License.
//  */
import android.content
import android.os
import android.support.v4.app
import android.support.v4.view
import android.support.v4.widget
import android.view
import android.widget

//  namespace com.example.android.swiperefreshlistfragment
//  /**
//  * Subclass of {@link android.support.v4.app.ListFragment} which provides automatic support for
//  * providing the 'swipe-to-refresh' UX gesture by wrapping the the content view in a
//  * {@link android.support.v4.widget.SwipeRefreshLayout}.
//  */
class SwipeRefreshListFragment: ListFragment {
	var mSwipeRefreshLayout: SwipeRefreshLayout!

	override func onCreateView(_ inflater: LayoutInflater!, _ container: ViewGroup!, _ savedInstanceState: Bundle!) -> View! {
		//  // Create the list fragment's content view by calling the super method
		var listFragmentView: View! = super.onCreateView(inflater, container, savedInstanceState)
		//  // Now create a SwipeRefreshLayout to wrap the fragment's content view
		mSwipeRefreshLayout = ListFragmentSwipeRefreshLayout(container.getContext(), parent: self)
		//  // Add the list fragment's content view to the SwipeRefreshLayout, making sure that it fills
		//  // the SwipeRefreshLayout
		mSwipeRefreshLayout.addView(listFragmentView, ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT)
		//  // Make sure that the SwipeRefreshLayout will fill the fragment
		mSwipeRefreshLayout.setLayoutParams(ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT))
		//  // Now return the SwipeRefreshLayout as this fragment's content view
		return mSwipeRefreshLayout
	}

	func setOnRefreshListener(_ listener: SwipeRefreshLayout.OnRefreshListener!) {
		mSwipeRefreshLayout.setOnRefreshListener(listener)
	}

	func isRefreshing() -> Bool {
		return mSwipeRefreshLayout.isRefreshing()
	}

	func setRefreshing(_ refreshing: Bool) {
		mSwipeRefreshLayout.setRefreshing(refreshing)
	}

	func setColorScheme(_ colorRes1: Int32, _ colorRes2: Int32, _ colorRes3: Int32, _ colorRes4: Int32) {
		mSwipeRefreshLayout.setColorScheme(colorRes1, colorRes2, colorRes3, colorRes4)
	}

	func getSwipeRefreshLayout() -> SwipeRefreshLayout! {
		return mSwipeRefreshLayout
	}

	//  /**
	//  * Sub-class of {@link android.support.v4.widget.SwipeRefreshLayout} for use in this
	//  * {@link android.support.v4.app.ListFragment}. The reason that this is needed is because
	//  * {@link android.support.v4.widget.SwipeRefreshLayout} only supports a single child, which it
	//  * expects to be the one which triggers refreshes. In our case the layout's child is the content
	//  * view returned from
	//  * {@link android.support.v4.app.ListFragment#onCreateView(android.view.LayoutInflater, android.view.ViewGroup, android.os.Bundle)}
	//  * which is a {@link android.view.ViewGroup}.
	//  *
	//  * <p>To enable 'swipe-to-refresh' support via the {@link android.widget.ListView} we need to
	//  * override the default behavior and properly signal when a gesture is possible. This is done by
	//  * overriding {@link #canChildScrollUp()}.
	//  */
	class ListFragmentSwipeRefreshLayout: SwipeRefreshLayout {
		var mParent: SwipeRefreshListFragment!
		
		init(_ context: Context!, parent: SwipeRefreshListFragment!) {
			super.init(context)
			mParent = parent
		}

		override func canChildScrollUp() -> Bool {
			var listView: ListView! = mParent.getListView()
			if listView.getVisibility() == android.view.View.VISIBLE {
				return canListViewScrollUp(listView)
			}
			else {
				return false
			}
		}
	}


	class func canListViewScrollUp(_ listView: ListView!) -> Bool {
		if android.os.Build.VERSION.SDK_INT >= 14 {
			//  // For ICS and above we can call canScrollVertically() to determine this
			return ViewCompat.canScrollVertically(listView, -1)
		}
		else {
			//  // Pre-ICS we need to manually check the first visible item and the child view's top
			//  // value
			return (listView.getChildCount() > 0) & ((listView.getFirstVisiblePosition() > 0) | (listView.getChildAt(0).getTop() < listView.getPaddingTop()))
		}
	}
}
