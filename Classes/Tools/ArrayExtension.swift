//
//  ArrayExtension.swift
//  HSIDCardFrameworkTest
//
//  Created by farben on 2020/10/22.
//  Copyright © 2020 farben. All rights reserved.
//

import Foundation

extension Array {
  /// Creates a new array from the bytes of the given unsafe data.
  ///
  /// - Warning: The array's `Element` type must be trivial in that it can be copied bit for bit
  ///     with no indirection or reference-counting operations; otherwise, copying the raw bytes in
  ///     the `unsafeData`'s buffer to a new array returns an unsafe copy.
  /// - Note: Returns `nil` if `unsafeData.count` is not a multiple of
  ///     `MemoryLayout<Element>.stride`.
  /// - Parameter unsafeData: The data containing the bytes to turn into an array.
    init?(unsafeData: Data) {
    let num = MemoryLayout<Element>.stride;
    print("Num个数:\(num).DataCount:\(unsafeData.count)")
    
    guard unsafeData.count % MemoryLayout<Element>.stride == 0 else { return nil }
    #if swift(>=5.0)
    print("ElementType:\(Element.self).")
    
    self = unsafeData.withUnsafeBytes {
        .init($0.bindMemory(to: Element.self))
    }
    #else
    self = unsafeData.withUnsafeBytes {
      .init(UnsafeBufferPointer<Element>(
        start: $0,
        count: unsafeData.count / MemoryLayout<Element>.stride
      ))
    }
    #endif  // swift(>=5.0)
   }
   
    
}



