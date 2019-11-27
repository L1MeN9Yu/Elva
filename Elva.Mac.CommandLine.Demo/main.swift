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

try Brotli.compress(
        inputFile: temp.appendingPathComponent("1574736566.json"),
        outputFile: temp.appendingPathComponent("1574736566.json.br")
).get()

try Brotli.decompress(
        inputFile: temp.appendingPathComponent("1574736566.json.br"), 
        outputFile: temp.appendingPathComponent("1574736566.json.br.de.json")
).get()