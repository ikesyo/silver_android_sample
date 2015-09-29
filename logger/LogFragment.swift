/*
* Copyright 2013 The Android Open Source Project
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*	 http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/
/*
 * Copyright 2013 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *	 http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import android.graphics
import android.os
import android.support.v4.app
import android.text
import android.view
import android.widget

/**
 * Simple fraggment which contains a LogView and uses is to output log data it receives
 * through the LogNode interface.
 */
class LogFragment: Fragment {

	var mLogView: LogView!
	var mScrollView: ScrollView!

	init() {}

	func inflateViews() -> View! {
		mScrollView = ScrollView(getActivity())
		let scrollParams = ViewGroup.LayoutParams(
				ViewGroup.LayoutParams.MATCH_PARENT,
				ViewGroup.LayoutParams.MATCH_PARENT);
		mScrollView.setLayoutParams(scrollParams);

		mLogView = LogView(getActivity());
		let logParams = ViewGroup.LayoutParams(scrollParams);
		logParams.height = ViewGroup.LayoutParams.WRAP_CONTENT;
		mLogView.setLayoutParams(logParams);
		mLogView.setClickable(true);
		mLogView.setFocusable(true);
		mLogView.setTypeface(Typeface.MONOSPACE);

		// Want to set padding as 16 dips, setPadding takes pixels.  Hooray math!
		let paddingDips = 16.0;
		let scale = getResources().getDisplayMetrics().density;
		let paddingPixels = Int(((paddingDips * scale) + 0.5));
		mLogView.setPadding(paddingPixels, paddingPixels, paddingPixels, paddingPixels);
		mLogView.setCompoundDrawablePadding(paddingPixels);

		mLogView.setGravity(Gravity.BOTTOM);
		mLogView.setTextAppearance(getActivity(), android.R.style.TextAppearance_Holo_Medium);

		mScrollView.addView(mLogView);
		return mScrollView;
	}

	func onCreateView(inflater: LayoutInflater, container: ViewGroup, savedInstanceState: Bundle) -> View! {
		var result = inflateViews()

		mLogView.addTextChangedListener(MyTextWatcher(self))
		return result
	}

	func getLogView() -> LogView! {
		return mLogView
	}
}

private class MyTextWatcher: TextWatcher {
	let fragment: LogFragment!
	
	init(_ fragment: LogFragment!) {
		self.fragment = fragment
	}
	
	func beforeTextChanged(s: CharSequence!, _ start: Integer, _ count: Integer, _ after: Integer) {}

	func onTextChanged(s: CharSequence!, _ start: Integer, _ before: Integer, _ count: Integer) {}

	func afterTextChanged(s: Editable!) {
		fragment.mScrollView.fullScroll(ScrollView.FOCUS_DOWN)
	}
}
