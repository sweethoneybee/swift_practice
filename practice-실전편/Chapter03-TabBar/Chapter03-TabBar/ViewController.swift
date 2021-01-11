//
//  ViewController.swift
//  Chapter03-TabBar
//
//  Created by 정성훈 on 2021/01/09.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let title = UILabel(frame: CGRect(x: 0, y: 100, width: 100, height: 30))
        
        title.text = "첫 번째 탭"
        title.textColor = .red
        title.textAlignment = .center
        title.font = UIFont.boldSystemFont(ofSize: 14)
        
        title.sizeToFit()
        
        title.center.x = self.view.frame.width / 2
        
        self.view.addSubview(title)
    }
    
    // 탭 바 토글 처리
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let tabBar = self.tabBarController?.tabBar
//        tabBar?.isHidden = (tabBar?.isHidden == true) ? false : true
        
        UIView.animate(withDuration: TimeInterval(0.15)) {
            // alpha 값이 0이면 1로, 1이면 0으로 바꾸어 준다.
            // 호출될 때마다 점점 투명해졌다가 점점 진해질 것이다
            tabBar?.alpha = (tabBar?.alpha == 0) ? 1 : 0
        }
    }


}

