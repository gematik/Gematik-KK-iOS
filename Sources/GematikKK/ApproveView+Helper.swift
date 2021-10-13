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

import SwiftUI

extension ApproveView {
    struct FooterView: View {
        var body: some View {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Development Helper")
                        .font(.headline)

                    Button(action: {
                        guard let url = URL(string: "https://erezept.dev.gematik.solutions"),
                              UIApplication.shared.canOpenURL(url) else {
                                  return
                              }
                        UIApplication.shared.open(url,
                                                  options: [UIApplication.OpenExternalURLOptionsKey
                                                                .universalLinksOnly: true]) { result in
                            print("UIApplication.open(url:options:completion) result: ", result)
                        }
                    }, label: {
                        Text("Jump Back")
                    })
                }
                Spacer()
            }
            .ignoresSafeArea()
            .padding()
            .background(Color(.secondarySystemBackground).ignoresSafeArea())
        }
    }

    struct TitleView: View {
        var body: some View {
            Text("GematikKK - Demo App")
                .font(.title)
                .padding()

            Button(action: {
                guard let url = URL(
                    string: "https://wiki.gematik.de/pages/viewpage.action?spaceKey=TIIAM&title=Testspec+Fasttrack&preview=/430113177/430115732/image2021-9-15_14-24-5.png" // swiftlint:disable:this line_length
                ) else {
                    return
                }
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }, label: {
                HStack {
                    Image(systemName: "link")

                    Text("For individual steps description, see wiki.gematik.de")
                }
            })
            .padding()
        }
    }

    struct EndpointPicker: View {
        @Binding var endpoint: ViewModel.ERecipeEndpoint

        var body: some View {
            VStack(alignment: .leading) {
                Picker("Output Environment:", selection: $endpoint) {
                    ForEach(ViewModel.ERecipeEndpoint.allCases, id: \.self) { endpoint in
                        Text("\(endpoint.description)")
                            .tag(endpoint)
                    }
                }.pickerStyle(MenuPickerStyle())
                .font(.subheadline)

                Text("\(endpoint.description)")
                    .font(.footnote)
                    .foregroundColor(Color(.secondaryLabel))
            }
        }
    }
}
