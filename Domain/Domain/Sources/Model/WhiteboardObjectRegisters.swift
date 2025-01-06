//
//  WhiteboardObjectRegisters.swift
//  Domain
//
//  Created by 박승찬 on 1/6/25.
//

import Foundation

actor WhiteboardObjectRegisters: WhiteboardObjectRegistersInterface {
    private var registers: Set<LWWRegister>

    init() {
        registers = []
    }

    func contains(register: LWWRegister) async -> Bool {
        registers.contains(register)
    }

    func insert(register: LWWRegister) async {
        registers.insert(register)
    }

    func remove(register: LWWRegister) async {
        registers.remove(register)
    }

    func removeAll() async {
        registers.removeAll()
    }

    func update(register: LWWRegister) async {
        guard let targetRegister = registers.first(where: { $0 == register }) else {
            await insert(register: register)
            return
        }
        targetRegister.merge(register: register)
    }

    func fetchObjectByID(id: UUID) async -> LWWRegister? {
        registers.first(where: { $0.whiteboardObject.id == id })
    }

    func fetchAll() async -> [LWWRegister] {
        Array(registers.sorted { $0 < $1 })
    }
}
