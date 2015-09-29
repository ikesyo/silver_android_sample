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
import android.os
import android.support.v4.widget
import android.view
import android.widget
import java.util

//  namespace com.example.android.swiperefreshlistfragment
//  /**
//  * A sample which shows how to use {@link android.support.v4.widget.SwipeRefreshLayout} within a
//  * {@link android.support.v4.app.ListFragment} to add the 'swipe-to-refresh' gesture to a
//  * {@link android.widget.ListView}. This is provided through the provided re-usable
//  * {@link SwipeRefreshListFragment} class.
//  *
//  * <p>To provide an accessible way to trigger the refresh, this app also provides a refresh
//  * action item. This item should be displayed in the Action Bar's overflow item.
//  *
//  * <p>In this sample app, the refresh updates the ListView with a random set of new items.
//  *
//  * <p>This sample also provides the functionality to change the colors displayed in the
//  * {@link android.support.v4.widget.SwipeRefreshLayout} through the options menu. This is meant to
//  * showcase the use of color rather than being something that should be integrated into apps.
//  */
class SwipeRefreshListFragmentFragment: SwipeRefreshListFragment {
	static let LOG_TAG: String! = SwipeRefreshListFragmentFragment.self.getSimpleName()
	static let LIST_ITEM_COUNT: Int32 = 20

	override func onCreate(_ savedInstanceState: Bundle!) {
		super.onCreate(savedInstanceState)
		// Notify the system to allow an options menu for this fragment.
		setHasOptionsMenu(true)
	}

	override func onViewCreated(_ view: View!, _ savedInstanceState: Bundle!) {
		super.onViewCreated(view, savedInstanceState)
		//  /**
		//  * Create an ArrayAdapter to contain the data for the ListView. Each item in the ListView
		//  * uses the system-defined simple_list_item_1 layout that contains one TextView.
		//  */
		var adapter: ListAdapter! = ArrayAdapter<String!>(getActivity(), android.R.layout.simple_list_item_1, android.R.id.text1, Cheeses.randomList(LIST_ITEM_COUNT))
		// Set the adapter between the ListView and its backing data.
		setListAdapter(adapter)
		// BEGIN_INCLUDE (setup_refreshlistener)
		//  /**
		//  * Implement {@link SwipeRefreshLayout.OnRefreshListener}. When users do the "swipe to
		//  * refresh" gesture, SwipeRefreshLayout invokes
		//  * {@link SwipeRefreshLayout.OnRefreshListener#onRefresh onRefresh()}. In
		//  * {@link SwipeRefreshLayout.OnRefreshListener#onRefresh onRefresh()}, call a method that
		//  * refreshes the content. Call the same method in response to the Refresh action from the
		//  * action bar.
		//  */
		setOnRefreshListener(SwipeRefreshLayout.OnRefreshListener(onRefresh: {
			Log.i(SwipeRefreshListFragmentFragment.LOG_TAG, "onRefresh called from SwipeRefreshLayout")
			
			self.initiateRefresh()
		}))
	}

	override func onCreateOptionsMenu(_ menu: Menu!, _ inflater: MenuInflater!) {
		inflater.inflate(R.menu.main_menu, menu)
	}

	override func onOptionsItemSelected(_ item: MenuItem!) -> Bool {
		switch item.getItemId() {
			case R.id.menu_refresh: {
				Log.i(LOG_TAG, "Refresh menu item selected")
				// We make sure that the SwipeRefreshLayout is displaying it's refreshing indicator
				if ~isRefreshing() {
					setRefreshing(true)
				}
				// Start our refresh background task
				initiateRefresh()
				return true
			}
			case R.id.menu_color_scheme_1: {
				Log.i(LOG_TAG, "setColorScheme #1")
				item.setChecked(true)
				// Change the colors displayed by the SwipeRefreshLayout by providing it with 4
				// color resource ids
				setColorScheme(R.color.color_scheme_1_1, R.color.color_scheme_1_2, R.color.color_scheme_1_3, R.color.color_scheme_1_4)
				return true
			}
			case R.id.menu_color_scheme_2: {
				Log.i(LOG_TAG, "setColorScheme #2")
				item.setChecked(true)
				// Change the colors displayed by the SwipeRefreshLayout by providing it with 4
				// color resource ids
				setColorScheme(R.color.color_scheme_2_1, R.color.color_scheme_2_2, R.color.color_scheme_2_3, R.color.color_scheme_2_4)
				return true
			}
			case R.id.menu_color_scheme_3: {
				Log.i(LOG_TAG, "setColorScheme #3")
				item.setChecked(true)
				// Change the colors displayed by the SwipeRefreshLayout by providing it with 4
				// color resource ids
				setColorScheme(R.color.color_scheme_3_1, R.color.color_scheme_3_2, R.color.color_scheme_3_3, R.color.color_scheme_3_4)
				return true
			}
			default:
		}
		return super.onOptionsItemSelected(item)
	}

	func initiateRefresh() {
		Log.i(LOG_TAG, "initiateRefresh")

		/**
		 * Execute the background task, which uses {@link android.os.AsyncTask} to load the data.
		 */
		DummyBackgroundTask(self).execute()
	}

	func onRefreshComplete(_ result: List<String!>!) {
		Log.i(LOG_TAG, "onRefreshComplete")
		// Remove all items from the ListAdapter, and then replace them with the new items
		var adapter: ArrayAdapter<String!>! = getListAdapter() as? ArrayAdapter<String!>
		adapter.clear()
		for cheese in result {
			adapter.add(cheese)
		}
		// Stop the refreshing indicator
		setRefreshing(false)
	}

	// END_INCLUDE (refresh_complete)

	//  /**
	//  * Dummy {@link AsyncTask} which simulates a long running task to fetch new cheeses.
	//  */
	class DummyBackgroundTask: AsyncTask<Void, Void, List<String!>!> {
		static let TASK_DURATION: Int = 3 * 1000; // 3 seconds
		
		let parent: SwipeRefreshListFragmentFragment!
		
		init(_ parent: SwipeRefreshListFragmentFragment!) {
			self.parent = parent
		}
		
		override func doInBackground(params: Void[]) -> List<String!>! {
			// Sleep for a small amount of time to simulate a background-task
			__try {
				Thread.sleep(TASK_DURATION);
			} __catch (e: InterruptedException!) {
				e.printStackTrace();
			}

			// Return a new random list of cheeses
			return Cheeses.randomList(LIST_ITEM_COUNT);
		}
		
		override func onPostExecute(result: List<String!>!) {
			super.onPostExecute(result);

			// Tell the Fragment that the refresh has completed
			parent.onRefreshComplete(result);
		}
	}
}
