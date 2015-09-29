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

//  namespace com.example.android.common.activities
//  /**
//  * Base launcher activity, to handle most of the common plumbing for samples.
//  */
class SampleActivityBase: FragmentActivity {
	let TAG: String! = "SampleActivityBase"

	override func onCreate(_ savedInstanceState: Bundle!) {
		super.onCreate(savedInstanceState)
	}

	override func onStart() {
		super.onStart()
		initializeLogging()
	}

	func initializeLogging() {
		//  // Using Log, front-end to the logging chain, emulates android.util.log method signatures.
		//  // Wraps Android's native log framework
		var logWrapper: LogWrapper! = LogWrapper()
		Log.setLogNode(logWrapper)
		Log.i(TAG, "Ready")
	}
}
