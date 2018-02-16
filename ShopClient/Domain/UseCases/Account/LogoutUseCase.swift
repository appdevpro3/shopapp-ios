//
//  LogoutUseCase.swift
//  ShopClient
//
//  Created by Radyslav Krechet on 12/27/17.
//  Copyright © 2017 Evgeniy Antonov. All rights reserved.
//

import ShopClient_Gateway

class LogoutUseCase {
    private lazy var repository = AppDelegate.getRepository()

    func logout(_ callback: @escaping (_ isLoggedOut: Bool) -> Void) {
        repository.logout { (success, _) in
            callback(success == true)
        }
    }
}
