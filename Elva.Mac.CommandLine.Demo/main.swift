//
//  main.swift
//  Elva.Mac.CommandLine.Demo
//
//  Created by Mengyu Li on 2019/11/22.
//  Copyright © 2019 Mengyu Li. All rights reserved.
//

import Foundation
import Elva

Elva.register(environment: Env.self)

guard let temp = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first?.appendingPathComponent("temp") else { exit(1) }

let inputData =
        """
        先有华为后有天，疏油闪存绿光边。
        莱卡三摄秒单反，浴霸炮筒炸神仙。
        海军余威震天响, 海思麒麟傲人间。
        华而不实任我为，不买你就是汉奸。
        """.data(using: .utf8)!

let zstdResult = ZSTD.compress(data: inputData).flatMap { compressedData -> Result<Data, ZSTD.Error> in
    print("\(compressedData)")
    return ZSTD.decompress(data: compressedData)
}

switch zstdResult {
case .success(let data):
    let string = String(data: data, encoding: .utf8)!
    print("\(string)")
case .failure(_):
    exit(1)
}

//try Brotli.compress(
//        inputFile: temp.appendingPathComponent("1574736566.json"),
//        outputFile: temp.appendingPathComponent("1574736566.json.br")
//).get()
//
//try Brotli.decompress(
//        inputFile: temp.appendingPathComponent("1574736566.json.br"),
//        outputFile: temp.appendingPathComponent("1574736566.json.br.de.json")
//).get()