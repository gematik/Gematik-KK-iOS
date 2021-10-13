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
import SwiftUI

class ViewModel: NSObject, ObservableObject, URLSessionDataDelegate {
    /// Constructed Request for Step 7
    @Published
    var request: AuthenticationRequest?

    /// Universal link to call for Step 8
    @Published
    var universalLink: URL?

    /// Response from Sectoral IDP of Step 7
    @Published
    var response: AuthorizationResponse?

    /// In case of an error, a simple message is displayed
    @Published
    var errorMessage: String?

    @Published
    var endpoint: ERecipeEndpoint = .dev

    enum ERecipeEndpoint: String, CaseIterable, CustomStringConvertible {
        var description: String {
            rawValue
        }

        case dev = "https://erezept.dev.gematik.solutions/extauth/"
        case ru = "https://das-e-rezept-fuer-deutschland.de/extauth/" // swiftlint:disable:this identifier_name
    }

    lazy var session = URLSession(configuration: .default, delegate: self, delegateQueue: .main)

    static let redirectURI = "https://kk.dev.gematik.solutions/redirect"

    func authorize(_ request: AuthenticationRequest) {
        guard var components = URLComponents(string: "https://idpsek.dev.gematik.solutions/authorization") else {
            return
        }
        components.queryItems = []
        components.queryItems?.append(URLQueryItem(name: "client_id", value: request.clientId))
        components.queryItems?.append(URLQueryItem(name: "state", value: request.state))
        components.queryItems?.append(URLQueryItem(name: "redirect_uri", value: Self.redirectURI))
        components.queryItems?.append(URLQueryItem(name: "code_challenge", value: request.codeChallenge))
        components.queryItems?.append(URLQueryItem(name: "code_challenge_method", value: request.codeChallengeMethod))
        components.queryItems?.append(URLQueryItem(name: "response_type", value: request.responseType))
        components.queryItems?.append(URLQueryItem(name: "nonce", value: request.nonce))
        components.queryItems?.append(URLQueryItem(name: "scope", value: request.scope))
        guard let url = components.url else { return }
        var request = URLRequest(url: url)
        request.addValue("FsMxoUGiJZowZ99lg7AfFYZl9/oEZ8jpMvCuMDhbAKE=", forHTTPHeaderField: "X-Authorization")

        let dataTask = URLSession.shared.dataTask(with: request) { _, response, _ in
            DispatchQueue.main.async {
                guard let url = response?.url,
                    var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
                    self.errorMessage = "Failed to deconstruct redirect url"
                    return
                }
                let redirectHost = components.host ?? "" + components.path
                components.queryItems?.append(URLQueryItem(name: "kk_app_redirect_uri", value: redirectHost))
                components.scheme = "https"
                components.host = "erezept.dev.gematik.solutions"
                components.port = nil
                components.path = "/extauth/"

                self.universalLink = components.url
                guard let response = try? AuthorizationResponse(with: url) else {
                    return
                }
                self.response = response

                print("universal link: ", components.url ?? "invalid url")
            }
        }
        dataTask.resume()
    }

    func urlSession(_: URLSession, task _: URLSessionTask,
                    willPerformHTTPRedirection response: HTTPURLResponse,
                    newRequest request: URLRequest,
                    completionHandler: @escaping (URLRequest?) -> Void) {
        // is redirect?
        if response.statusCode == 302,
           let url = response.url {
            self.response = try? AuthorizationResponse(with: url)
            completionHandler(nil)
        } else {
            completionHandler(request)
        }
    }

    func processERezeptLogin(with url: URL) {
        request = try? AuthenticationRequest(with: url)
    }

    func launchERezeptApp() {
        guard let universalLink = self.universalLink,
              var components = URLComponents(url: universalLink, resolvingAgainstBaseURL: true),
              let targetEnvironmentURL = URL(string: endpoint.rawValue) else { return }

        components.scheme = targetEnvironmentURL.scheme
        components.host = targetEnvironmentURL.host
        components.port = targetEnvironmentURL.port
        components.path = targetEnvironmentURL.path

        guard let finalUniversalLink = components.url else {
            return
        }

        UIApplication.shared.open(
            finalUniversalLink,
            options: [.universalLinksOnly: true]
        ) { completion in
            print("completion:", completion)
        }
    }
}

struct ApproveView: View {
    @ObservedObject
    var viewModel: ViewModel

    var body: some View {
        VStack(alignment: .leading) {
            TitleView()

            if let request = viewModel.request {
                HStack {
                    Image(systemName: "arrow.down.right")
                        .font(.largeTitle)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Authorization Request received")
                        Text("Ready for Steps 4 - 7, Input for Step 4:")
                            .font(.subheadline)
                            .foregroundColor(Color(.secondaryLabel))

                        ScrollView(.horizontal) {
                            Text(request.description)
                                .multilineTextAlignment(.leading)
                                .font(.system(.footnote, design: .monospaced))
                        }

                        Button {
                            viewModel.authorize(request)
                        } label: {
                            Text("Procced")
                                .padding()
                        }
                    }

                    Spacer()
                }
                .padding()
                .background(Color(.secondarySystemBackground))
            }

            if let response = viewModel.response {
                HStack {
                    VStack {
                        Image(systemName: "arrow.up.backward")
                            .font(.largeTitle)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Authorization Response received")
                        Text("Ready for Step 8, Output")
                            .font(.subheadline)
                            .foregroundColor(Color(.secondaryLabel))

                        ScrollView(.horizontal) {
                            Text(response.description)
                                .multilineTextAlignment(.leading)
                                .font(.system(.footnote, design: .monospaced))
                        }

                        EndpointPicker(endpoint: $viewModel.endpoint)

                        Button {
                            viewModel.launchERezeptApp()
                        } label: {
                            Text("Open E-Rezept App")
                                .padding(.vertical)
                        }
                    }

                    Spacer()
                }
                .padding()
                .background(Color(.secondarySystemBackground))
            }

            Spacer()

            FooterView()

        }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct Preview: PreviewProvider {
    static var previews: some View {
        ApproveView(viewModel: ViewModel())
    }
}
