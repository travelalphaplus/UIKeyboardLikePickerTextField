//
//  UIKeyboardLikePickerTextField.swift
//  Gia Ola
//
//  Created by George Tsifrikas on 16/12/15.
//  Copyright © 2015 George Tsifrikas. All rights reserved.
//

import UIKit

public class UIKeyboardLikePickerTextField: UITextField, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    static var picker:UIPickerView?
    static var pickerToolbar:UIToolbar?
    static var picketToolbarButton: UIBarButtonItem?
    weak var otherDelegate: UITextFieldDelegate? = nil;
    weak private var parentView:UIView?
    
    override weak public var delegate: UITextFieldDelegate? {
        get {
            return self
        }
        set(newDelegate) {
            otherDelegate = newDelegate
        }
    }
    
    public var pickerDataSource:[String] = [] {
        didSet {
            focusedOnMe()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        super.delegate = self
        checkStatus()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        super.delegate = self
        checkStatus()
    }
    
    private func checkStatus() {
        if UIKeyboardLikePickerTextField.picker == nil {
            self.createPicker()
        }
        self.inputAccessoryView = UIKeyboardLikePickerTextField.pickerToolbar
        self.inputView = UIKeyboardLikePickerTextField.picker
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "focusedOnMe", name: UITextViewTextDidBeginEditingNotification, object: nil)
    }
    
    func focusedOnMe() {
        UIKeyboardLikePickerTextField.picker?.dataSource = self
        UIKeyboardLikePickerTextField.picker?.delegate = self
        UIKeyboardLikePickerTextField.picker?.reloadAllComponents()
        if self.text == "" {
            UIKeyboardLikePickerTextField.picker?.selectRow(0, inComponent: 0, animated: false)
        } else {
            var index = 0
            for option in self.pickerDataSource {
                if option == self.text {
                    UIKeyboardLikePickerTextField.picker?.selectRow(index + 1, inComponent: 0, animated: false)
                }
                index += 1
            }
        }
    }
    
    private func createPicker() {
        var heightOfPicker:CGFloat = 216
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            if UIDevice.current.orientation == .portrait || UIDevice.current.orientation == .portraitUpsideDown {
                heightOfPicker = 264
            } else {
                heightOfPicker = 352
            }
        } else {
            if UIDevice.current.orientation == .portrait || UIDevice.current.orientation == .portraitUpsideDown {
                heightOfPicker = 216
            } else {
                heightOfPicker = 162
            }
        }
        heightOfPicker += 20
        let screenHeight = UIScreen.main.bounds.size.height
        
        let picker = UIPickerView(frame: CGRect(x: 0, y: screenHeight - heightOfPicker, width: UIScreen.main.bounds.size.width, height: heightOfPicker))
        UIKeyboardLikePickerTextField.picker = picker
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
//        toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        let doneButton = UIBarButtonItem(title: "Done".localizedString, style: UIBarButtonItem.Style.done, target: self, action: #selector(donePressed))
//        var cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: "cancelPressed")
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        toolBar.sizeToFit()
        UIKeyboardLikePickerTextField.pickerToolbar = toolBar
        self.inputAccessoryView = toolBar
    }
    
    @objc func donePressed() {
        _ = self.textFieldShouldReturn(self)
    }
    
    //MARK: - text filed self delegate
    public func textFieldDidBeginEditing(_ textField: UITextField){
        otherDelegate?.textFieldDidBeginEditing?(textField);
    }
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        focusedOnMe()
        return otherDelegate?.textFieldShouldBeginEditing?(textField) ?? true
    }
    
    public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return otherDelegate?.textFieldShouldEndEditing?(textField) ?? true
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        otherDelegate?.textFieldDidEndEditing?(textField)
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        return otherDelegate?.textField?(textField, shouldChangeCharactersIn: range, replacementString: string) ?? true
    }
    
    public func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return otherDelegate?.textFieldShouldClear?(textField) ?? true
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return otherDelegate?.textFieldShouldReturn?(textField) ?? true
    }

    //MARK: - picker delegate
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.pickerDataSource.count + 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.text = row == 0 ? "" : self.pickerDataSource[row - 1]
    }
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return row > 0 ? self.pickerDataSource[row - 1] : ""
    }
}


extension String {
    var localizedString: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
}
