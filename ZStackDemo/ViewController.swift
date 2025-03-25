//
//  ViewController.swift
//  ZStackDemo
//
//  Created by mac on 2025/3/25.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 创建 ZStack 容器
        let zStack = ZStackView(alignment: .center)
        zStack.backgroundColor = .lightGray

        // 添加第一个子视图
        let redView = UIView()
        redView.backgroundColor = .red.withAlphaComponent(0.5)
//        redView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            redView.widthAnchor.constraint(equalToConstant: 120),
//            redView.heightAnchor.constraint(equalToConstant: 80)
//        ])
        zStack.addArrangedSubview(redView)
        redView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 120, height: 80))
        }

        // 添加第二个子视图（覆盖在上方）
        let blueView = UIView()
        blueView.backgroundColor = .blue.withAlphaComponent(0.5)
        blueView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            blueView.widthAnchor.constraint(equalToConstant: 60),
//            blueView.heightAnchor.constraint(equalToConstant: 60)
//        ])
        zStack.addArrangedSubview(blueView)
        blueView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 60, height: 60))
        }

        // 添加到父视图并自动布局
        view.addSubview(zStack)
        NSLayoutConstraint.activate([
            zStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            zStack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
//            zStack.widthAnchor.constraint(equalToConstant: 200),
//            zStack.heightAnchor.constraint(equalToConstant: 200)
        ])
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//            zStack.removeArrangedSubview(redView)
//            redView.isHidden = true
            
//            NSLayoutConstraint.deactivate(blueView.constraints)
//            blueView.widthAnchor.constraint(equalToConstant: 300).isActive = true
            redView.isHidden = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            redView.isHidden = false
        }
        
        // Do any additional setup after loading the view.
    }


}

