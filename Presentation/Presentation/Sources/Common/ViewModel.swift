//
//  ViewModel.swift
//  Presentation
//
//  Created by 이동현 on 11/13/24.
//

protocol ViewModel {
    associatedtype Input
    associatedtype Output
    
    func action(input: Input)
}
