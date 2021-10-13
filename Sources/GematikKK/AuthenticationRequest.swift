//
//  Copyright (c) 2021 gematik GmbH
//  
//  Licensed under the EUPL, Version 1.2 or – as soon they will be approved by
//  the European Commission - subsequent versions of the EUPL (the Licence);
//  You may not use this work except in compliance with the Licence.
//  You may obtain a copy of the Licence at:
//  
//      https://joinup.ec.europa.eu/software/page/eupl
//  
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the Licence is distributed on an "AS IS" basis,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the Licence for the specific language governing permissions and
//  limitations under the Licence.
//  
//

import Foundation

struct AuthenticationRequest {
    let clientId: String
    let state: String
    let redirectURI: String
    let codeChallenge: String
    let codeChallengeMethod: String
    let responseType: String
    let nonce: String
    let scope: String

    enum Error: Swift.Error {
        case initializationError
    }

    init(with url: URL) throws {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            throw Error.initializationError
        }

        clientId = try components.forcedQueryItem(for: "client_id")
        state = try components.forcedQueryItem(for: "state")
        redirectURI = try components.forcedQueryItem(for: "redirect_uri")
        codeChallenge = try components.forcedQueryItem(for: "code_challenge")
        codeChallengeMethod = try components.forcedQueryItem(for: "code_challenge_method")
        responseType = try components.forcedQueryItem(for: "response_type")
        nonce = try components.forcedQueryItem(for: "nonce")
        scope = try components.forcedQueryItem(for: "scope")
    }
}

extension AuthenticationRequest: CustomStringConvertible {
    var description: String {
        """
client_id:              \(clientId)
state:                  \(state)
redirect_uri:           \(redirectURI)
code_challenge:         \(codeChallenge)
code_challenge_method:  \(codeChallengeMethod)
response_type:          \(responseType)
nonce:                  \(nonce)
scope:                  \(scope)
"""
    }
}
