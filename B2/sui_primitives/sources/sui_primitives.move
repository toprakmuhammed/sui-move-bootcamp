module sui_primitives::sui_primitives;
#[test_only]
use sui::dynamic_field;
#[test_only]
use sui::dynamic_object_field;
#[test_only]
use std::string::{String};
#[test_only]
use sui::test_scenario;

const EInvalidNumber: u64 = 601;

#[test]
fun test_numbers() {
    let a = 50;
    let b = 50;
    assert!(a == b, 601);

    //Task 1 : A ile b'yi toplayıp değerini kontrol et.

    let c = a + b;
    assert!(c == 100, 404);
}

#[test, expected_failure]
fun test_overflow() {
    let a: u8 = 255;
    let b: u8 = 1;

    assert!(a + b == 0, 604);

    //
}

#[test]
fun test_mutability() {
    let mut a = 10;
    a = a + 20;

}

#[test]
fun test_boolean() {
    let a = 200;
    let b = 500;
    let c = b > a;
    assert!(c, EInvalidNumber);
    // TAsk 2: ki tane integer sayı tutun biri diğerinden büyük mü diye kontrol edin

}

#[test]
fun test_loop() {

    let mut result = 1;
    let mut i = 2;
    while (i <= 5) {
        result = result * i;
        i = i + 1;
        std::debug::print(&result);
        std::debug::print(&i);
    };
    assert!(result == 120, 608);

}

#[test]
fun test_vector() {
    let mut myVec: vector<u8> = vector[10, 20, 30];

    assert!(myVec.length() == 3, 609);

    assert!(myVec.is_empty(), 610);

    while (myVec.length() > 0) {
        myVec.pop_back();
    };

    //Bir döngü açıp vektörün içindeki değerlerin uzunluğu 0 olana kadar pop_back yapın.
    //Buna bakalım
    assert!(myVec.length() == 0, 611);
    assert!(myVec.is_empty(), 610);
}

#[test]
fun test_string() {
    let myStringArr: vector<u8> = b"Hello, World!";

    //ikinci indexin değerinin 108'e eşit olup olmadığını test edin
    assert!(myStringArr[2] == 108, 613);
}

#[test]
fun test_string2() {
    let myStringArr = b"Hello, World!";
    //Task 6: W'nun idexini bulalım. W = 87
    assert!(myStringArr[7] == 87, 666);
}

public struct Container has key {
    id: UID,
}

public struct Item has key, store {
    id: UID,
    value: u64,
}

#[test]
fun test_dynamic_fields() {
    let mut test_scenario = test_scenario::begin(@0xCAFE);
    let mut container = Container {
        id: object::new(test_scenario.ctx()),
    };

    // PART 1: Dynamic Fields
    dynamic_field::add(&mut container.id, b"score", 100u64);
    let score = dynamic_field::borrow(&container.id, b"score");
    assert!(score == 100, 123);
    dynamic_field::remove<vector<u8>, u64>(&mut container.id, b"score");
    assert!(!dynamic_field::exists_(&container.id, b"score"), 124);

    // PART 2: Dynamic Object Fields
    let item = Item {
        id: object::new(test_scenario.ctx()),
        value: 500,
    };
    dynamic_object_field::add(&mut container.id, b"item", item);
    let item_ref = dynamic_object_field::borrow<vector<u8>, Item>(&container.id, b"item");
    assert!(item_ref.value == 500, 125);
    let item = dynamic_object_field::remove<vector<u8>, Item>(&mut container.id, b"item");
    assert!(!dynamic_object_field::exists_(&container.id, b"item"), 126);
    let Item { id, value: _ } = item;
    object::delete(id);

    // Clean up
    let Container {
        id,
    } = container;
    object::delete(id);
    test_scenario.end();
}
