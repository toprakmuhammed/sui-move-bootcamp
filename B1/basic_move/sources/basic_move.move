module basic_move::basic_move;
use std::string::String;

#[test_only]
use sui::test_scenario;

#[test_only]
use sui::test_utils::destroy;
//contractı başarıyla compile edin.

//Heroya name field ekle, tipi string olsun.
public struct Hero has key, store {
    id: object::UID,
    name:String
}



public struct InsignificantWeapon has drop, store {
    power: u8,
}

//Weapon adında bir struct yazın, yukarıdakinin aynısı olsun tek farkı, ability olmasın.

public struct Weapon has store {
    power: u8,
}

public fun mint_hero(name: String, ctx: &mut TxContext): Hero {
    Hero { id: object::new(ctx), name}
}

public fun create_insignificant_weapon(power: u8): InsignificantWeapon {
    InsignificantWeapon { power }
}

public fun create_weapon (power: u8):Weapon {
    Weapon {power}
}

//Weapon için create fonksiyonu yazın.

#[test]
fun test_mint() {
    let mut scenario = test_scenario::begin(@ruro);

    let hero = mint_hero(b"ruro".to_string(), scenario.ctx());

//oluşturulan heronun isminin doğru olup olmadığını kontrol edin. eğer yanlışsa 65 hata kodunu döndürün.

    assert!(hero.name == b"ruro".to_string(), 65);


    std::debug::print(&hero);

    destroy(hero);
    scenario.end();
}

// Aynı şeyler: test_scenario::ctx(test)); == test.ctx()

#[test]
fun test_drop_semantics() {
    let _i_weapon = create_insignificant_weapon(99);

    let mut _i2_weapon = create_insignificant_weapon(100);
    _i2_weapon = create_insignificant_weapon(101);

    let weapon = create_weapon(10);
    destroy(weapon);
}
   
//Bir Insignificant Weapon oluşturun. Ardından bu test casei çalıştırın.
//closed loop  token ödev.

