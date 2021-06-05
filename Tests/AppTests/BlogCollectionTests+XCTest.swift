import XCTest

///
/// NOTE: This file was generated by generate_linux_tests.py
///
/// Do NOT edit this file directly as it will be regenerated automatically when needed.
///

extension BlogCollectionTests {

    @available(*, deprecated, message: "not actually deprecated. Just deprecated to allow deprecated tests (which test deprecated functionality) without warnings")
    static var allTests: [(String, (BlogCollectionTests) -> () throws -> Void)] {
        return [
            ("testAuthorizeRequire", testAuthorizeRequire),
            ("testCreate", testCreate),
            ("testCreateWithoutContent", testCreateWithoutContent),
            ("testQueryWithIDThatDoesNotExsit", testQueryWithIDThatDoesNotExsit),
            ("testQueryWithID", testQueryWithID),
            ("testUpdate", testUpdate),
            ("testUpdateBlogWithNewCategory", testUpdateBlogWithNewCategory),
            ("testUpdateBlogWithRemoveCategory", testUpdateBlogWithRemoveCategory),
            ("testUpdateBlogAlias", testUpdateBlogAlias),
            ("testDeleteWithIDThatDoesNotExsit", testDeleteWithIDThatDoesNotExsit),
            ("testDelete", testDelete),
        ]
    }
}
