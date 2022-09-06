//
//  FirmPressContextMenu.swift
//  FirmPressDetector
//
//  Created by Raphael Tang on 4/9/22.
//

import SwiftUI
import SnapKit

class ContextMenuViewController<Content: View>: UIViewController {
    private var content: UIHostingController<Content>
    private var chidoriMenu: ChidoriMenu?
    
    private lazy var touchDetector = TouchDetectingUIView()
    private lazy var menu = UIMenu(
        title: "test",
        options: .displayInline,
        children: [
            UIAction(title: "Favorite", image: UIImage(systemName: "star")) { _ in
            },
            UIAction(title: "Edit", image: UIImage(systemName: "pencil")) { _ in
            }
        ]
    )
    
    init(_ content: Content) {
        self.content = UIHostingController(rootView: content)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func presentMenu(at: CGPoint) {
        chidoriMenu = ChidoriMenu(menu: menu, summonPoint: at)
        guard let chidoriMenu = chidoriMenu else {
            return
        }
        chidoriMenu.delegate = self
        present(chidoriMenu, animated: true, completion: nil)
    }
    
    func onTouchDetected(_ position: CGPoint, _ radius: CGFloat) {
        if let chidoriMenu = chidoriMenu {
            if chidoriMenu.isBeingPresented {
                return
            }
        }
        if FingerSizeModel().isFirmPress(size: Float(radius)) {
            presentMenu(at: view.convert(view.center, to: view.window))
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.touchDetector.onUpdate = TouchDetectingData.shared.notifyHandlers
        TouchDetectingData.shared.addOnUpdateCallback(self.onTouchDetected)
        self.add(content) { make in
            make.width.height.centerX.centerY.equalTo(self.view)
        }
        self.view.addSubview(touchDetector)
        self.touchDetector.snp.makeConstraints { make in
            make.width.height.centerX.centerY.equalTo(self.view)
        }
        
        self.view.translatesAutoresizingMaskIntoConstraints = false
        self.touchDetector.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func viewDidLayoutSubviews() {
        preferredContentSize = view.bounds.size
    }
}

extension UIViewController {
    func add(_ child: UIViewController) {
        addChild(child)
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }
    
    func add(_ child: UIViewController, constraints: @escaping (ConstraintMaker) -> Void) {
        self.add(child)
        child.view.snp.makeConstraints(constraints)
    }
    
    @discardableResult func addView<Content: View>(_ child: Content) -> UIHostingController<Content> {
        let uiView = UIHostingController(rootView: child)
        self.add(uiView)
        return uiView
    }
    
    @discardableResult func addView<Content: View>(_ child: Content, constraints: @escaping (ConstraintMaker) -> Void) -> UIHostingController<Content> {
        let uiView = self.addView(child)
        uiView.view.snp.makeConstraints(constraints)
        return uiView
    }
    
    func remove() {
        // Just to be safe, we check that this view controller
        // is actually added to a parent before removing it.
        guard parent != nil else {
            return
        }

        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
}

extension ContextMenuViewController: ChidoriDelegate {
    func didSelectAction(_ action: UIAction) {
        print("Chidori menu item selected: \(action)")
    }
}

struct ContextMenu<Content: View>: UIViewControllerRepresentable {
    var content: Content
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content()
    }
    
    typealias UIViewControllerType = ContextMenuViewController<Content>
    
    func makeUIViewController(context: Context) -> UIViewControllerType {
        return ContextMenuViewController(content)
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    }
}

extension View {
    func contextMenu() -> some View {
        return ContextMenu(content: {self})
    }
}

struct FirmPressContextMenu_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("test").contextMenu()
        }
    }
}
