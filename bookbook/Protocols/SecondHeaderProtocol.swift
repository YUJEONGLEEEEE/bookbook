//
//  SecondHeaderProtocol.swift
//  bookbook
//
//  Created by 이유정 on 9/19/25.
//

import Foundation

protocol SecondHeaderProtocol: AnyObject {
    func secondHeaderView(_ headerView: SecondHeaderView, didSelectItemAt indexPath: IndexPath)
}
