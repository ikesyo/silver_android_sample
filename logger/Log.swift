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
//  namespace com.example.android.common.logger
//  /**
//  * Helper class for a list (or tree) of LoggerNodes.
//  *
//  * <p>When this is set as the head of the list,
//  * an instance of it can function as a drop-in replacement for {@link android.util.Log}.
//  * Most of the methods in this class server only to map a method call in Log to its equivalent
//  * in LogNode.</p>
//  */
class Log {
	// Grabbing the native values from Android's native logging facilities,
	// to make for easy migration and interop.
	static let NONE: Int32 = -1
	static let VERBOSE: Int32 = android.util.Log.VERBOSE
	static let DEBUG: Int32 = android.util.Log.DEBUG
	static let INFO: Int32 = android.util.Log.INFO
	static let WARN: Int32 = android.util.Log.WARN
	static let ERROR: Int32 = android.util.Log.ERROR
	static let ASSERT: Int32 = android.util.Log.ASSERT
	
	// Stores the beginning of the LogNode topology.
	static var logNode: LogNode?

	class func println(_ priority: Int32, _ tag: String!, _ msg: String!, _ tr: Throwable!) {
		logNode?.println(priority, tag, msg, tr)
	}

	class func println(_ priority: Int32, _ tag: String!, _ msg: String!) {
		println(priority, tag, msg, nil)
	}

	class func v(_ tag: String!, _ msg: String!, _ tr: Throwable!) {
		println(VERBOSE, tag, msg, tr)
	}

	class func v(_ tag: String!, _ msg: String!) {
		v(tag, msg, nil)
	}

	class func d(_ tag: String!, _ msg: String!, _ tr: Throwable!) {
		println(DEBUG, tag, msg, tr)
	}

	class func d(_ tag: String!, _ msg: String!) {
		d(tag, msg, nil)
	}

	class func i(_ tag: String!, _ msg: String!, _ tr: Throwable!) {
		println(INFO, tag, msg, tr)
	}

	class func i(_ tag: String!, _ msg: String!) {
		i(tag, msg, nil)
	}

	class func w(_ tag: String!, _ msg: String!, _ tr: Throwable!) {
		println(WARN, tag, msg, tr)
	}

	class func w(_ tag: String!, _ msg: String!) {
		w(tag, msg, nil)
	}

	class func w(_ tag: String!, _ tr: Throwable!) {
		w(tag, nil, tr)
	}

	class func e(_ tag: String!, _ msg: String!, _ tr: Throwable!) {
		println(ERROR, tag, msg, tr)
	}

	class func e(_ tag: String!, _ msg: String!) {
		e(tag, msg, nil)
	}

	class func wtf(_ tag: String!, _ msg: String!, _ tr: Throwable!) {
		println(ASSERT, tag, msg, tr)
	}

	class func wtf(_ tag: String!, _ msg: String!) {
		wtf(tag, msg, nil)
	}

	class func wtf(_ tag: String!, _ tr: Throwable!) {
		wtf(tag, nil, tr)
	}
}
