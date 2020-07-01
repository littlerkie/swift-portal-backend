//===----------------------------------------------------------------------===//
//
// This source file is part of the website-backend open source project
//
// Copyright © 2020 Eli Zhang, and the website-backend project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import XCTVapor
@testable import App

func assertHttpUnauthorized(_ response: XCTHTTPResponse) throws {
    XCTAssertEqual(response.status, .unauthorized)
}

func assertHttpOk(_ response: XCTHTTPResponse) throws {
    XCTAssertEqual(response.status, .ok)
}

func assertHttpNotFound(_ response: XCTHTTPResponse) throws {
    XCTAssertEqual(response.status, .notFound)
}

func assertHttpServerError(_ response: XCTHTTPResponse) throws {
    XCTAssertEqual(response.status, .internalServerError)
}

func assertHttpBadRequest(_ response: XCTHTTPResponse) throws {
    XCTAssertEqual(response.status, .badRequest)
}

@discardableResult
func registUserAndLoggedIn(
    _ app: Application,
    _ username: String = "test",
    _ password: String = "111111",
    headers: HTTPHeaders? = nil
) throws -> HTTPHeaders {

    var httpHeaders = headers
    guard httpHeaders == nil else {
        try completion?(httpHeaders!)
        return httpHeaders!
    }

    try app.test(.POST, "users", beforeRequest: {
        try $0.content.encode(User.Creation.init(username: username, password: password))
    }, afterResponse: {
        XCTAssertEqual($0.status, .ok)

        let authorizeMsg = try $0.content.decode(AuthorizeMsg.self)

        XCTAssertNotNil(authorizeMsg.accessToken)
        XCTAssertNotNil(authorizeMsg.user)
        XCTAssertNotNil(authorizeMsg.user.id)
        XCTAssertEqual(authorizeMsg.user.username, username)
        XCTAssertNil(authorizeMsg.user.name)
        XCTAssertNil(authorizeMsg.user.screenName)
        XCTAssertNil(authorizeMsg.user.phone)
        XCTAssertNil(authorizeMsg.user.emailAddress)
        XCTAssertNil(authorizeMsg.user.aboutMe)
        XCTAssertNil(authorizeMsg.user.location)
        XCTAssertNil(authorizeMsg.user.eduExps)
        XCTAssertNil(authorizeMsg.user.jobExps)

        httpHeaders = HTTPHeaders.init(dictionaryLiteral: ("Authorization", "Bearer " + authorizeMsg.accessToken))
    })

    return httpHeaders!
}

@discardableResult
func assertCreateNetworkingService(
    _ app: Application,
    service: SocialNetworkingService.Coding = socialNetworkingService
) throws -> SocialNetworkingService.Coding {

    var service: SocialNetworkingService.Coding!

    try app.test(.POST, "social/services", beforeRequest: {
        try $0.content.encode(socialNetworkingService)
    }, afterResponse: {
        XCTAssertEqual($0.status, .ok)

        let coding = try $0.content.decode(SocialNetworkingService.Coding.self)
        XCTAssertNotNil(coding.id)
        XCTAssertNotNil(coding.type)
        XCTAssertEqual(coding.html, socialNetworkingService.html)
        XCTAssertNil(coding.imageUrl)

        service = coding
    })

    return service
}

@discardableResult
func assertCreateSocial(
    _ app: Application,
    headers: HTTPHeaders? = nil
) throws -> (HTTPHeaders, Social.Coding) {

    var tuple: (HTTPHeaders, Social.Coding)!

    try assertCreateNetworkingService(app, completion: { [unowned app] serviceID in
        try registUserAndLoggedIn(app, headers: headers, completion: { headers in
            try app.test(.POST, "social", headers: headers, beforeRequest: {
                try $0.content.encode(Social.Coding.init(url: "https://twitter.com/uid", networkingServiceId: serviceID))
            }, afterResponse: {
                XCTAssertEqual($0.status, .ok)
                let coding = try $0.content.decode(Social.Coding.self)

                XCTAssertNotNil(coding.id)
                XCTAssertNotNil(coding.userId)
                XCTAssertEqual(coding.url, "https://twitter.com/uid")
                XCTAssertNotNil(coding.networkingService)
                XCTAssertEqual(coding.networkingService?.id, serviceID)

                try completion?(headers, coding)

                tuple = (headers, coding)
            })
        })
    })

    return tuple
}

@discardableResult
func assertCreateIndustry(
    _ app: Application,
    industry: Industry.Coding? = nil
) throws -> Industry.Coding {

    var coding: Industry.Coding!

    try app.test(.POST, Industry.schema, beforeRequest: {
        try $0.content.encode(industry ?? Industry.Coding.init(title: "International Trade & Development"))
    }, afterResponse: {
        XCTAssertEqual($0.status, .ok)

        coding = try $0.content.decode(Industry.Coding.self)
        XCTAssertNotNil(coding.id)
        XCTAssertEqual(coding.title, industry?.title ?? "International Trade & Development")

    })

    return coding
}