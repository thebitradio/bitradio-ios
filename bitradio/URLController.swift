//
//  URLController.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2017-05-26.
//  Copyright © 2017 breadwallet LLC. All rights reserved.
//

import UIKit

class URLController : Trackable {

    init(store: Store, walletManager: WalletManager) {
        self.store = store
        self.walletManager = walletManager
    }

    private let store: Store
    private let walletManager: WalletManager
    private var xSource, xSuccess, xError, uri: String?

    func handleUrl(_ url: URL) -> Bool {
        /*saveEvent("send.handleURL", attributes: [
            "scheme" : url.scheme ?? C.null,
            "host" : url.host ?? C.null,
            "path" : url.path
        ])*/

        switch url.scheme ?? "" {
        case "bitradiowallet":
            if let query = url.query {
                for component in query.components(separatedBy: "&") {
                    let pair = component.components(separatedBy: "+")
                    if pair.count < 2 { continue }
                    let key = pair[0]
                    var value = String(component[component.index(key.endIndex, offsetBy: 2)...])
                    value = (value.replacingOccurrences(of: "+", with: " ") as NSString).removingPercentEncoding!
                    switch key {
                    case "x-source":
                        xSource = value
                    case "x-success":
                        xSuccess = value
                    case "x-error":
                        xError = value
                    case "uri":
                        uri = value
                    default:
                        print("Key not supported: \(key)")
                    }
                }
            }

            if url.host == "scanqr" || url.path == "/scanqr" {
                store.trigger(name: .scanQr)
            } else if url.host == "addresslist" || url.path == "/addresslist" {
                store.trigger(name: .copyWalletAddresses(xSuccess, xError))
            } else if url.path == "/address" {
                if let success = xSuccess {
                    copyAddress(callback: success)
                }
            } else if let uri = isBitcoinUri(url: url, uri: uri) {
                return handleBitcoinUri(uri)
            }
            return true
            
        case "bitradio":
            return handleBitcoinUri(url)
            
        default:
            return false
        }
    }

    private func isBitcoinUri(url: URL, uri: String?) -> URL? {
        guard let uri = uri else { return nil }
        guard let bitcoinUrl = URL(string: uri) else { return nil }
        if (url.host == "bitradio-uri" || url.path == "/bitradio-uri") && bitcoinUrl.scheme == "bitradio" {
            return url
        } else {
            return nil
        }
    }

    private func copyAddress(callback: String) {
        if let url = URL(string: callback), let wallet = walletManager.wallet {
            let queryLength = url.query?.utf8.count ?? 0
            let callback = callback.appendingFormat("%@address=%@", queryLength > 0 ? "&" : "?", wallet.receiveAddress)
            if let callbackURL = URL(string: callback) {
                UIApplication.shared.openURL(callbackURL)
            }
        }
    }

    private func handleBitcoinUri(_ uri: URL) -> Bool {
        if let request = PaymentRequest(string: uri.absoluteString) {
            store.trigger(name: .receivedPaymentRequest(request))
            return true
        } else {
            return false
        }
    }

    private func present(alert: UIAlertController) {
        store.trigger(name: .showAlert(alert))
    }
}
