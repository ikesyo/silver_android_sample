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
import android.app
import android.content
import android.util
import android.widget

//  namespace com.example.android.common.logger
//  /** Simple TextView which is used to output log data received through the LogNode interface.
//  */
class LogView: TextView, LogNode {
	init(_ context: Context!) {
		super.init(context)
	}

	init(_ context: Context!, _ attrs: AttributeSet!) {
		super.init(context, attrs)
	}

	init(_ context: Context!, _ attrs: AttributeSet!, _ defStyle: Int32) {
		super.init(context, attrs, defStyle)
	}

	func println(_ priority: Int32, _ tag: String!, _ msg: String!, _ tr: Throwable!) {
		var priorityStr: String! = nil
		// For the purposes of this View, we want to print the priority as readable text.
		switch priority {
			case android.util.Log.VERBOSE: {
				priorityStr = "VERBOSE"
				break
			}
			case android.util.Log.DEBUG: {
				priorityStr = "DEBUG"
				break
			}
			case android.util.Log.INFO: {
				priorityStr = "INFO"
				break
			}
			case android.util.Log.WARN: {
				priorityStr = "WARN"
				break
			}
			case android.util.Log.ERROR: {
				priorityStr = "ERROR"
				break
			}
			case android.util.Log.ASSERT: {
				priorityStr = "ASSERT"
				break
			}
			default: {
				break
			}
		}
		// Handily, the Log class has a facility for converting a stack trace into a usable string.
		var exceptionStr: String! = nil
		if tr != nil {
			exceptionStr = android.util.Log.getStackTraceString(tr)
		}
		// Take the priority, tag, message, and exception, and concatenate as necessary
		// into one usable line of text.
		var outputBuilder: StringBuilder! = StringBuilder()
		var delimiter: String! = "\t"
		appendIfNotNull(outputBuilder, priorityStr, delimiter)
		appendIfNotNull(outputBuilder, tag, delimiter)
		appendIfNotNull(outputBuilder, msg, delimiter)
		appendIfNotNull(outputBuilder, exceptionStr, delimiter)
		// In case this was originally called from an AsyncTask or some other off-UI thread,
		// make sure the update occurs within the UI thread.
		(getContext() as? Activity)?.runOnUiThread(Thread(Runnable(run: {
			// Display the text we just generated within the LogView.
			self.appendToLog(outputBuilder.toString());
		})))

		next?.println(priority, tag, msg, tr)
	}

	func appendIfNotNull(_ source: StringBuilder!, _ addStr: String!, _ delimiter: String!) -> StringBuilder! {
		if addStr != nil {
			if addStr.length() == 0 {
				delimiter = ""
			}
			return source.append(addStr).append(delimiter)
		}
		return source
	}

	// The next LogNode in the chain.
	var next: LogNode?

	func appendToLog(_ s: String!) {
		append("\r" + s)
	}
}
