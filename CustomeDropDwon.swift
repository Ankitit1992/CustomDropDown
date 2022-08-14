//
//  SoCoDropDown.swift
//  DropDownDemo
//
//  Created by Ankit Tiwari on 27/06/22.
//

import Foundation
import UIKit

class SoCoDropDownCell: UITableViewCell {
}

protocol SoCoContentDropDownDelegate: NSObjectProtocol {
    func didUserSelectAddButton(_ button: UIButton)
    func didUserSelectItem(at indexPath: Int, _ view: UIView, _ value: String)
    func didUserRemoveDropDown(from view: UIView)
}

class SoCoContentDropDown: NSObject {
    private var dataSourceList = [String]()
    private var transparentView = UIView()
    private var selectedValue = ""
    private var topAnchor = 0.0
    lazy var button: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.layer.borderColor = UIColor.socoBorder.cgColor
        button.setTitleColor(.socoBlue, for: .normal)
        button.titleLabel?.font = UIFont.socoButtonSemibold14Font()
        button.layer.borderWidth = 1.0
        button.layer.cornerRadius = 5.0
        button.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        button.setTitle(R.string.commonStrings.editPaperBillButtonTitle(), for: .normal)
        button.addTarget(self, action: #selector(onClickAddBtn(_:)), for: .touchUpInside)
        return button
    }()
    private var selectedView = UIView()
    weak var delegate: SoCoContentDropDownDelegate?
    lazy var tableView: UITableView  = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.layer.borderColor = UIColor.socoBorder.cgColor
        tableView.layer.borderWidth = 1.0
        tableView.separatorStyle = .none
        return tableView
    }()

     override init() {
        super.init()
    }

    func addTransparentView(in view: UIView, with list: [String], _ selectedView: UIView, _ selectedValue: String, _ topAnchor: Double = 0.0) {
        self.selectedView = selectedView
        self.topAnchor = topAnchor
        self.selectedValue = selectedValue
        dataSourceList = list
        transparentView.frame = view.frame
        transparentView.backgroundColor = .clear
        view.addSubview(transparentView)
        tableView.frame = CGRect(x: selectedView.frame.origin.x, y: selectedView.frame.origin.y + selectedView.frame.height - self.topAnchor, width: selectedView.frame.width, height: 0)
        button.frame = CGRect(x: tableView.frame.origin.x, y: tableView.frame.origin.y + tableView.frame.height, width: tableView.frame.width, height: 45)
        view.addSubview(tableView)
        view.addSubview(button)
        tableView.register(SoCoDropDownCell.self, forCellReuseIdentifier: "SoCoDropDown")
        addTapGesture()
        tableView.reloadData()
    }

    @objc func onClickAddBtn(_ sender: UIButton) {
        delegate?.didUserSelectAddButton(sender)
        removeTableView()
    }
    private func addTapGesture() {
        var height = 0.0
        let view = selectedView
        let addTapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureHandler(_:)))
        transparentView.addGestureRecognizer(addTapGesture)
        UIView.animate(withDuration: 0.4,
                       delay: 0.0,
                       usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 1.0,
                       options: .curveEaseInOut) { [weak self] in
            guard let self = self else {return}
            self.transparentView.alpha = 0.5
            if self.dataSourceList.count <= 2 {
                height =  Double(self.dataSourceList.count) * 50.0
            } else {
                height = Double(self.dataSourceList.count) * 50.0 < 200 ? Double(self.dataSourceList.count) * 50.0 : 200
            }
            self.tableView.frame = CGRect(x: view.frame.origin.x, y: view.frame.origin.y + view.frame.height - self.topAnchor, width: view.frame.width, height: height)
            self.button.frame = CGRect(x: self.tableView.frame.origin.x, y: self.tableView.frame.origin.y + self.tableView.frame.height, width: self.tableView.frame.width, height: 45)
        } completion: { _ in
        }
        
    }
    
    @objc private func tapGestureHandler(_ tapGesture: UITapGestureRecognizer) {
        removeTableView()
    }
    
    private func removeTableView() {
        let view = selectedView
        UIView.animate(withDuration: 0.4,
                       delay: 0.0,
                       usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 1.0,
                       options: .curveEaseInOut) { [weak self] in
            guard let self = self else {return}
            self.transparentView.alpha = 0
            self.tableView.frame = CGRect(x: view.frame.origin.x, y: view.frame.origin.y + view.frame.height - self.topAnchor, width: view.frame.width, height: 0)
            self.button.frame = CGRect(x: self.tableView.frame.origin.x, y: self.tableView.frame.origin.y + self.tableView.frame.height, width: self.tableView.frame.width, height: 0)
            self.delegate?.didUserRemoveDropDown(from: self.selectedView)
        } completion: { _ in
        }
        self.button.frame = .zero
    }
}

extension SoCoContentDropDown: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSourceList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard  let cell =  tableView.dequeueReusableCell(withIdentifier: "SoCoDropDown", for: indexPath) as? SoCoDropDownCell else {return UITableViewCell()}
        indexPath.row == 0 ? cell.setSelected(true, animated: true) : cell.setSelected(false, animated: true)
        cell.textLabel?.text = dataSourceList[indexPath.row]
        cell.textLabel?.numberOfLines = 0
        cell.imageView?.isAccessibilityElement = true
        cell.imageView?.accessibilityLabel = selectedValue == dataSourceList[indexPath.row] ? SoCoStrings.radioButtonSelected : SoCoStrings.radioButton
       cell.imageView?.image =   selectedValue == dataSourceList[indexPath.row] ? UIImage(named: "radioButtonRed") : UIImage(named: "radioButtonGray")
        cell.textLabel?.font =  selectedValue == dataSourceList[indexPath.row] ? UIFont.socoButtonSemiboldFont() : UIFont.socoSubtitleLightFont()
        cell.textLabel?.textColor =  selectedValue == dataSourceList[indexPath.row] ? UIColor.socoBlue : UIColor.socoPrimaryGrey
        cell.textLabel?.isAccessibilityElement = true
        cell.imageView?.accessibilityTraits = .none
        cell.selectionStyle = .none
        tableView.allowsSelection = true
        return cell
    }
}

extension SoCoContentDropDown: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.reloadData()
        removeTableView()
        delegate?.didUserSelectItem(at: indexPath.row, selectedView, dataSourceList[indexPath.row])
    }
}
