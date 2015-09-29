//  /*
//  * Copyright 2013 The Android Open Source Project
//  *
//  * Licensed under the Apache License, Version 2.0 (the "License");
//  * you may not use this file except in compliance with the License.
//  * You may obtain a copy of the License at
//  *
//  *	 http://www.apache.org/licenses/LICENSE-2.0
//  *
//  * Unless required by applicable law or agreed to in writing, software
//  * distributed under the License is distributed on an "AS IS" BASIS,
//  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  * See the License for the specific language governing permissions and
//  * limitations under the License.
//  */
import android.os
import android.support.v4.app
import android.view
import android.widget

//  namespace com.example.android.swiperefreshlistfragment
//  /**
//  * A simple launcher activity containing a summary sample description, sample log and a custom
//  * {@link android.support.v4.app.Fragment} which can display a view.
//  * <p>
//  * For devices with displays with a width of 720dp or greater, the sample log is always visible,
//  * on other devices it's visibility is controlled by an item on the Action Bar.
//  */
class MainActivity: SampleActivityBase {
	let TAG = "MainActivity"
	// Whether the Log Fragment is currently shown
	var mLogShown: Bool = false

	override func onCreate(_ savedInstanceState: Bundle!) {
		super.onCreate(savedInstanceState)
		setContentView(R.layout.activity_main)
		if savedInstanceState == nil {
			var transaction: FragmentTransaction! = getSupportFragmentManager().beginTransaction()
			var fragment: SwipeRefreshListFragmentFragment! = SwipeRefreshListFragmentFragment()
			transaction.replace(R.id.sample_content_fragment, fragment)
			transaction.commit()
		}
	}

	override func onCreateOptionsMenu(_ menu: Menu!) -> Bool {
		getMenuInflater().inflate(R.menu.main, menu)
		return true
	}

	override func onPrepareOptionsMenu(_ menu: Menu!) -> Bool {
		var logToggle: MenuItem! = menu.findItem(R.id.menu_toggle_log)
		logToggle.setVisible(findViewById(R.id.sample_output) is ViewAnimator)
		logToggle.setTitle(mLogShown ? R.string.sample_hide_log : R.string.sample_show_log)
		return super.onPrepareOptionsMenu(menu)
	}

	override func onOptionsItemSelected(_ item: MenuItem!) -> Bool {
		switch item.getItemId() {
			case R.id.menu_toggle_log: {
				mLogShown = ~mLogShown
				var output: ViewAnimator! = findViewById(R.id.sample_output) as? ViewAnimator
				if mLogShown {
					output.setDisplayedChild(1)
				}
				else {
					output.setDisplayedChild(0)
				}
				supportInvalidateOptionsMenu()
				return true
			}
			default:
		}
		return super.onOptionsItemSelected(item)
	}

	override func initializeLogging() {
		// Wraps Android's native log framework.
		let logWrapper = LogWrapper()
		// Using Log, front-end to the logging chain, emulates android.util.log method signatures.
		Log.logNode = logWrapper

		// Filter strips out everything except the message text.
		let msgFilter = MessageOnlyLogFilter()
		logWrapper.next = msgFilter

		// On screen logging via a fragment with a TextView.
		if let logFragment = getSupportFragmentManager().findFragmentById(R.id.log_fragment) as? LogFragment {
			msgFilter.next = logFragment.getLogView()
		}

		Log.i(TAG, "Ready")
	}
}
