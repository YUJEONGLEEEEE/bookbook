//
//  DetailViewController.swift
//  bookbook
//
//  Created by 이유정 on 9/16/25.
//

import UIKit
import Alamofire
import SnapKit

class DetailViewController: UIViewController {

    private let backgroundImage = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        return image
    }()

    private let blurView = {
        let blurEffect = UIBlurEffect(style: .light)
        let view = UIVisualEffectView(effect: blurEffect)
        return view
    }()

    private let bookImage: UIImageView = {
        let image = UIImageView()
        return image
    }()

    private let bookTitle: UILabel = {
        let label = UILabel()
        return label
    }()

    private let authorLabel: UILabel = {
        let label = UILabel()
        return label
    }()

    private let publisherLabel: UILabel = {
        let label = UILabel()
        return label
    }()

    private let isbnLabel: UILabel = {
        let label = UILabel()
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        return label
    }()

    private let linkButton: UIButton = {
        let button = UIButton()
        return button
    }()

    private let bookmarkButton: UIButton = {
        let button = UIButton()
        return button
    }()

    private let likeButton: UIButton = {
        let button = UIButton()
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureUI()

    }

    private func configureUI() {
    }


}

/*
 들어갈 내용: 썸네일, 책제목, 저자, 출판사, 출판연도, ISBN, 책소개, 좋아요
 */
