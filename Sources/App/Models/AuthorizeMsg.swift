//===----------------------------------------------------------------------===//
//
// This source file is part of the website-backend open source project
//
// Copyright © 2020 Eli Zhang and the website-backend project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import Vapor

struct AuthorizeMsg: Content {
    let user: User.Coding
    let accessToken: String

    init(user: User.Coding, token: Token) {
        self.user = user
        self.accessToken = token.token
    }
}