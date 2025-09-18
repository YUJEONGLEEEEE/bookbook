//
//  BookFilterProtocol.swift
//  bookbook
//
//  Created by 이유정 on 9/17/25.
//

import Foundation

protocol BookFilterProtocol: AnyObject {
    func bookFilterView(_ view: BookFilterView, didSelectFilter query:  String)
}
