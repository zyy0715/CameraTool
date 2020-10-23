//
//  DataConvert.swift
//  HSIDCardFrameworkTest
//
//  Created by farben on 2020/10/22.
//  Copyright © 2020 farben. All rights reserved.
//

import Foundation


class DataConvert: NSObject {
@objc func getResult( data:Data) -> Array<Any>{
    return Array<Float>.init(unsafeData: data) ?? [];
    }
}





