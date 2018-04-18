//
//  OldestBlockRequest.swift
//  breadwallet
//
//  Created by YoshiCarlsberg on 15.04.18.
//  Copyright © 2018 breadwallet LLC. All rights reserved.
//

import Foundation

struct AddressInfoJSON: Decodable {
    let addrStr: String
    let balance: Double
    let balanceSat: Int64
    let totalReceived: Double
    let totalReceivedSat: Int64
    let totalSent: Double
    let totalSentSat: Int64
    let unconfirmedBalance: Double
    let unconfirmedTxApperances: Int
    let transactions: [String]
}

struct TransactionJSON: Decodable {
    var txid: String
    var hash: String
    var version: Int
    var size: Int
    var blocktime: Int64
    var blockhash: String
}

class OldestBlockRequest {
    
    private struct Block {
        var hash: String
        var blockHeight: Int
        var blockTime: Int64
    }
    
    static let addressBaseURL = "https://digiexplorer.info/api/addr"
    static let txBaseURL = "https://digiexplorer.info/api/tx"
    static let blockBaseURL = "https://digiexplorer.info/api/block"
    private var oldestBlock: Block?
    let onCompletion: (Bool, String, Int, Int64) -> Void // success, hash, blockHeight, blockTime
    let session: URLSession
    let addresses: [String]
    
    var completed = false
    var callbackCalled = false
    // var lock = DispatchSemaphore(value: 1)
    
    private func next(_ callback: @escaping () -> Void) {
        // lock.wait()
        self.session.getAllTasks(completionHandler: { (tasks) in
            if !self.callbackCalled && tasks.count == 0 {
                self.callbackCalled = true
                // self.lock.signal()
                callback()
            }
        })
    }
    
    private func fetchTransactions(_ callback: @escaping ([String]) -> Void) {
        callbackCalled = false
        var transactions: [String] = []
        
        if self.addresses.count == 0 {
            return finish()
        }
        
        for i in 0 ..< self.addresses.count {
            let address = self.addresses[i]
            let url = "\(OldestBlockRequest.addressBaseURL)/\(address)"
            let dataTask = self.session.dataTask(with: URL(string: url)!, completionHandler: { (data, response, error) in
                if let err = error {
                    print("SYNC: ERROR", err);
                    self.next { callback(transactions) }
                    return;
                }
                
                guard let data = data else { return }
                do {
                    let parsedJSON = try JSONDecoder().decode(AddressInfoJSON.self, from: data)
                    
                    if let last = parsedJSON.transactions.last {
                        transactions.append(last)
                    }
                } catch let jsonErr {
                    print("SYNC: JSON ERROR", jsonErr);
                }
                
                self.next { callback(transactions) }
            })
            
            dataTask.resume()
        }
    }
    
    private func getBlocks(_ transactions: [String], callback: @escaping ([Block]) -> Void) {
        callbackCalled = false
        
        var blocks: [Block] = []
        for i in 0 ..< transactions.count {
            let transaction = transactions[i]
            
            let url = "\(OldestBlockRequest.txBaseURL)/\(transaction)"
            
            let dataTask = self.session.dataTask(with: URL(string: url)!, completionHandler: { (data, response, error) in
                if let err = error {
                    print("SYNC:2 ERROR", err);
                    self.next { callback(blocks) }
                    return;
                }
                
                guard let data = data else { return }
                do {
                    let parsedJSON = try JSONDecoder().decode(TransactionJSON.self, from: data)
                    blocks.append(Block(hash: parsedJSON.blockhash , blockHeight: 0, blockTime: parsedJSON.blocktime))
                } catch let jsonErr {
                    print("SYNC:2 JSON ERROR", jsonErr);
                }
                
                self.next { callback(blocks) }
            })
            
            dataTask.resume()
        }
    }
    
    private func finish() {
        if self.completed { return }
        completed = true
        
        if let b = oldestBlock {
            self.onCompletion(true, b.hash, b.blockHeight, b.blockTime)
        } else {
            self.onCompletion(true, "", 0, 0)
        }
    }
    
    private func getBlockHeight(_ blockHash: String, callback: @escaping (Int) -> Void) {
        let url = "\(OldestBlockRequest.blockBaseURL)/\(blockHash)"
        let dataTask = self.session.dataTask(with: URL(string: url)!, completionHandler: { (data, response, error) in
            guard let data = data else { return }
            do {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                callback(json!["height"] as! Int)
            } catch {
                print("Error deserializing JSON \(error)")
            }
        })
        dataTask.resume()
    }
    
    func start() {
        self.fetchTransactions { (transactions) in
            if transactions.count == 0 { return self.finish() }
            self.getBlocks(transactions, callback: { (blocks) in
                guard var oldestBlock = blocks.max(by: { (a, b) -> Bool in
                    return a.blockTime < b.blockTime
                }) else { return self.finish() }
                
                self.getBlockHeight(oldestBlock.hash, callback: { (height) in
                    oldestBlock.blockHeight = height
                    self.oldestBlock = oldestBlock
                    self.finish()
                })
            })
        }
    }
    
    init(_ addr: [String], completion: @escaping (Bool, String, Int, Int64) -> Void) {
        onCompletion = completion
        
        // create session
        let cfg = URLSessionConfiguration.default
        cfg.httpMaximumConnectionsPerHost = 3
        session = URLSession(configuration: cfg)
        self.addresses = addr
    }
}
