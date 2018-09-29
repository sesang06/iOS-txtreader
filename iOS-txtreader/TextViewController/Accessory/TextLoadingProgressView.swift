//
//  TextLoadingProgressView.swift
//  iOS-txtreader
//
//  Created by 조세상 on 2018. 9. 16..
//  Copyright © 2018년 조세상. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import RxCocoa
import RxSwift
class TextLoadingProgressView : UIView {
    var shapeLayer: CAShapeLayer!
    var pulsatingLayer: CAShapeLayer!
    var trackLayer : CAShapeLayer!
    var percentage : Variable<CGFloat?> = Variable(0)
    let percentageLabel: UILabel = {
        let label = UILabel()
        label.text = "Start"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 32)
        label.textColor = .white
        return label
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
//        print(frame)
        setUpViews()
        percentageCheck()
    }
    let disposeBag = DisposeBag()
    func percentageCheck(){
        let percentageCheck =
        percentage
            .asObservable()
            .throttle(0.1, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .observeOn(MainScheduler.instance)

            .subscribe(onNext: { [weak self] (percentage) in
                guard let percentage = percentage else {
                    return
                }
                self?.percentageLabel.text = "\(Int(percentage * 100))%"
                self?.shapeLayer.strokeEnd = percentage
            })
        .addDisposableTo(disposeBag)
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setUpViews(){
//        self.backgroundColor = .red
        setupCircleLayers()
        setupPercentageLabel()
        shapeLayer.strokeEnd = 0
        setupNotificationObservers()
        
        
    }
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleEnterForeground), name: .UIApplicationWillEnterForeground, object: nil)
    }
    
    @objc private func handleEnterForeground() {
        animatePulsatingLayer()
    }
    
    
    private func setupCircleLayers() {
        pulsatingLayer = createCircleShapeLayer(strokeColor: .clear, fillColor: UIColor.pulsatingFillColor)
        self.layer.addSublayer(pulsatingLayer)
        animatePulsatingLayer()
        
        trackLayer = createCircleShapeLayer(strokeColor: .trackStrokeColor, fillColor: .backgroundColor)
        self.layer.addSublayer(trackLayer)
        
        shapeLayer = createCircleShapeLayer(strokeColor: .outlineStrokeColor, fillColor: .clear)
        
        shapeLayer.transform = CATransform3DMakeRotation(-CGFloat.pi / 2, 0, 0, 1)
        shapeLayer.strokeEnd = 0
        self.layer.addSublayer(shapeLayer)
    }
    private func setupPercentageLabel() {
        
        self.addSubview(percentageLabel)
        percentageLabel.snp.makeConstraints { (make) in
            make.width.height.equalTo(100)
            make.center.equalTo(self)
        }
//        percentageLabel.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
//        percentageLabel.center = self.center
    }
    private func animatePulsatingLayer() {
//        let animation = CABasicAnimation(keyPath: "transform.scale")
//        
//        animation.toValue = 1.5
//        animation.duration = 0.8
//        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
//        animation.autoreverses = true
//        animation.repeatCount = Float.infinity
//        
//        pulsatingLayer.add(animation, forKey: "pulsing")
    }
    private func createCircleShapeLayer(strokeColor: UIColor, fillColor: UIColor) -> CAShapeLayer {
        let layer = CAShapeLayer()
        let circularPath = UIBezierPath(arcCenter: .zero, radius: 100, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
        layer.path = circularPath.cgPath
        layer.strokeColor = strokeColor.cgColor
        layer.lineWidth = 20
        layer.fillColor = fillColor.cgColor
        layer.lineCap = kCALineCapRound
        layer.position = self.center
        return layer
    }
    
    
}
