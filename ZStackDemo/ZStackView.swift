//
//  ZStackView.swift
//  ZStackDemo
//
//  Created by mac on 2025/3/25.
//

import Foundation
import UIKit

/// 对齐方式枚举（支持 SwiftUI 风格的对齐方式）
public enum ZStackAlignment {
    case center
    case leading
    case trailing
    case top
    case bottom
    case leadingTop
    case leadingBottom
    case trailingTop
    case trailingBottom
}

/// 仿 SwiftUI ZStack 的 UIKit 容器组件
public final class ZStackView: UIView {
    
    // MARK: - 属性
    
    private let alignment: ZStackAlignment
    private var arrangedSubviews: [UIView] = []
    private var observers: [NSKeyValueObservation] = []
    
    // MARK: - 初始化方法
    
    public init(alignment: ZStackAlignment = .center) {
        self.alignment = alignment
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        self.alignment = .center
        super.init(coder: coder)
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    deinit {
        // 清理所有 KVO 观察者
        observers.forEach { $0.invalidate() }
    }
    
    // MARK: - 动态子视图管理
    
    /// 添加子视图到 ZStack
    public func addArrangedSubview(_ view: UIView) {
        addSubview(view)
        arrangedSubviews.append(view)
        setupConstraints(for: view)
        observeViewChanges(view)
        invalidateIntrinsicContentSize()
    }
    
    /// 插入子视图到指定位置
    public func insertArrangedSubview(_ view: UIView, at index: Int) {
        insertSubview(view, at: index)
        arrangedSubviews.insert(view, at: index)
        setupConstraints(for: view)
        observeViewChanges(view)
        invalidateIntrinsicContentSize()
    }
    
    /// 移除子视图
    public func removeArrangedSubview(_ view: UIView) {
        guard let index = arrangedSubviews.firstIndex(of: view) else { return }
        arrangedSubviews.remove(at: index)
        view.removeFromSuperview()
        invalidateIntrinsicContentSize()
    }
    
    // MARK: - 布局约束配置
    
    private func setupConstraints(for view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        
        // 对齐约束
        switch alignment {
        case .center:
            NSLayoutConstraint.activate([
                view.centerXAnchor.constraint(equalTo: centerXAnchor),
                view.centerYAnchor.constraint(equalTo: centerYAnchor)
            ])
        case .leading:
            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: leadingAnchor),
                view.centerYAnchor.constraint(equalTo: centerYAnchor)
            ])
        case .trailing:
            NSLayoutConstraint.activate([
                view.trailingAnchor.constraint(equalTo: trailingAnchor),
                view.centerYAnchor.constraint(equalTo: centerYAnchor)
            ])
        case .top:
            NSLayoutConstraint.activate([
                view.centerXAnchor.constraint(equalTo: centerXAnchor),
                view.topAnchor.constraint(equalTo: topAnchor)
            ])
        case .bottom:
            NSLayoutConstraint.activate([
                view.centerXAnchor.constraint(equalTo: centerXAnchor),
                view.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        case .leadingTop:
            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: leadingAnchor),
                view.topAnchor.constraint(equalTo: topAnchor)
            ])
        case .leadingBottom:
            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: leadingAnchor),
                view.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        case .trailingTop:
            NSLayoutConstraint.activate([
                view.trailingAnchor.constraint(equalTo: trailingAnchor),
                view.topAnchor.constraint(equalTo: topAnchor)
            ])
        case .trailingBottom:
            NSLayoutConstraint.activate([
                view.trailingAnchor.constraint(equalTo: trailingAnchor),
                view.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        }
        
        // 动态边界约束
        NSLayoutConstraint.activate([
                    view.topAnchor.constraint(greaterThanOrEqualTo: topAnchor),
                    view.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor),
                    view.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),
                    view.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor)
                ])
    }
    
    override public var intrinsicContentSize: CGSize {
            let visibleSubviews = arrangedSubviews.filter { !$0.isHidden }
            guard !visibleSubviews.isEmpty else { return .zero }
            
            // 计算所有可见子视图的最大尺寸
            let sizes = visibleSubviews.map { view in
                // 优先使用约束计算的尺寸（兼容手动修改约束）
                let targetSize = CGSize(
                    width: UIView.layoutFittingCompressedSize.width,
                    height: UIView.layoutFittingCompressedSize.height
                )
                return view.systemLayoutSizeFitting(
                    targetSize,
                    withHorizontalFittingPriority: .fittingSizeLevel,
                    verticalFittingPriority: .fittingSizeLevel
                )
            }
            
            return sizes.reduce(.zero) { maxSize, size in
                CGSize(
                    width: max(maxSize.width, size.width),
                    height: max(maxSize.height, size.height)
                )
            }
        }
        
        // MARK: - 增强的监听方法
        private func observeViewChanges(_ view: UIView) {
            // 1. 监听bounds变化（约束/帧修改）
            let boundsObserver = view.observe(\.bounds) { [weak self] (_, _) in
                self?.setNeedsLayout()
            }
            
            // 2. 监听hidden变化（单独处理）
            let hiddenObserver = view.observe(\.isHidden, options: [.new, .old]) { [weak self] (_, change) in
                guard change.oldValue != change.newValue else { return }
                self?.handleHiddenStateChange()
            }
            
            observers.append(contentsOf: [boundsObserver, hiddenObserver])
        }
        
        // MARK: - 隐藏状态特殊处理
        private func handleHiddenStateChange() {
            // 立即更新约束优先级
            arrangedSubviews.forEach { view in
                let priority: UILayoutPriority = view.isHidden ? .defaultLow : .required
                view.constraints.forEach { $0.priority = priority }
            }
            
            // 强制两阶段布局更新
            setNeedsLayout()
            DispatchQueue.main.async { [weak self] in
                self?.superview?.setNeedsLayout()
            }
        }
        
        // MARK: - 终极布局更新
        override public func layoutSubviews() {
            super.layoutSubviews()
            invalidateIntrinsicContentSize()
            
            // 确保父视图同步更新
            if let superview = superview {
                superview.setNeedsLayout()
                superview.layoutIfNeeded()
            }
        }
}
