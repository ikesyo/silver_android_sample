//  /*
//  * Copyright (C) 2013 The Android Open Source Project
//  *
//  * Licensed under the Apache License, Version 2.0 (the "License");
//  * you may not use this file except in compliance with the License.
//  * You may obtain a copy of the License at
//  *
//  *      http://www.apache.org/licenses/LICENSE-2.0
//  *
//  * Unless required by applicable law or agreed to in writing, software
//  * distributed under the License is distributed on an "AS IS" BASIS,
//  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  * See the License for the specific language governing permissions and
//  * limitations under the License.
//  */
//  namespace com.example.android.common.logger
//  /**
//  * Simple {@link LogNode} filter, removes everything except the message.
//  * Useful for situations like on-screen log output where you don't want a lot of metadata displayed,
//  * just easy-to-read message updates as they're happening.
//  */
class MessageOnlyLogFilter: LogNode {
    var mNext: LogNode!

    init(_ next: LogNode!) {
        mNext = next
    }

    init() {
    }

    func println(_ priority: Int32, _ tag: String!, _ msg: String!, _ tr: Throwable!) {
        if mNext != nil {
            getNext().println(Log.NONE, nil, msg, nil)
        }
    }

    func getNext() -> LogNode! {
        return mNext
    }

    func setNext(_ node: LogNode!) {
        mNext = node
    }
}
