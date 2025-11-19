module publisher::hero {
    use std::string::String;
    use sui::package::{Self, Publisher};

    const EWrongPublisher: u64 = 1;

    public struct Hero has key {
        id: UID,
        name: String,
    }

    //OTW

    public struct HERO has drop {}

    fun init(otw: HERO,ctx: &mut TxContext) {
        // create Publisher and transfer it to the publisher wallet
        package::claim_and_keep(otw, ctx)

    }

    public fun create_hero(publisher: &Publisher, name: String, ctx: &mut TxContext): Hero {
        assert!(publisher.from_module<HERO>(), EWrongPublisher);
        // verify that publisher is from the same module

        // Yeni bir hero oluşturup return et.

        Hero {
            id: object::new(ctx),
            name
        }

        
    }

    public fun transfer_hero(publisher: &Publisher, hero: Hero, to: address) {

        assert!(publisher.from_module<HERO>(), EWrongPublisher);

        // Üstteki gibi publisherı kontrol et.

        // Heroyu to'ya transfer et. 
        transfer::transfer(hero, to)
    }

    // ===== TEST ONLY =====

    #[test_only]
    use sui::{test_scenario as ts, test_utils::{destroy}};
    #[test_only]
    use std::unit_test::assert_eq;

    #[test_only]
    const ADMIN: address = @0xAA;
    #[test_only]
    const USER: address = @0xCC;

    #[test]
    fun test_publisher_address_gets_publihser_object() {
        let mut ts = ts::begin(ADMIN);

        assert_eq!(ts::has_most_recent_for_address<Publisher>(ADMIN), false);

        init(HERO {}, ts.ctx());

        ts.next_tx(ADMIN);

        let publisher = ts.take_from_sender<Publisher>();
        assert_eq!(publisher.from_module<HERO>(), true);
        ts.return_to_sender(publisher);

        ts.end();
    }

    #[test]
    fun test_admin_can_create_hero() {
        let mut ts = ts::begin(ADMIN);

        init(HERO {}, ts.ctx());

        ts.next_tx(ADMIN);

        let publisher = ts.take_from_sender<Publisher>();

        let hero = create_hero(&publisher, b"Hero 1".to_string(), ts.ctx());

        assert_eq!(hero.name, b"Hero 1".to_string());

        ts.return_to_sender(publisher);

        destroy(hero);

        ts.end();
    }

    #[test]
    fun test_admin_can_transfer_hero() {
        // TODO: Implement test
        // Task 1: Testleri başarıyla tamamla. 
        // 1. Senaryoyu başlat (ADMIN).
        let mut test = ts::begin(ADMIN);
        // 2. init fonksiyonunu çağır.
        init(HERO {}, test.ctx());
        // 3. diğer tx'e geç. (ADMIN)
        test.next_tx(ADMIN);
        // 4. Publisher objesini kullanıcıdan al. 
        // 4.1. test.take_from_sender<Publisher>() (fonksiyonunu kullan)
        let publisher = test.take_from_sender<Publisher>();
        // 5. create_hero fonksiyonunu çağır. (Dikkat et bu fonksiyon retun yapıyor.)
        let hero = create_hero(&publisher, b"Hero 1".to_string(), test.ctx());
        // 6. transfer_hero fonksiyonunu çağır (User'a transfer et.)
        transfer_hero(&publisher, hero, USER);
        // 7. diğer tx'e geç. (ADMIN)
        test.next_tx(ADMIN);
        // 8. test::has_most_recent_for_address<Hero>(USER) kullanarak kullanıcıda Hero olduğunu doğrula.
        assert!(ts::has_most_recent_for_address<Hero>(USER), 101);
        // 9. Temizlik.
        // 9.1. test.return_to_sender(publisher) yap.
        test.return_to_sender(publisher);
        //10. testi bitir.
        test.end();
       
    }
}

#[test_only]
module publisher::hero_test {
    use publisher::hero;
    use sui::package::{Self, Publisher};
    use sui::test_scenario as ts;
    #[test_only]
    use std::unit_test::assert_eq;

    const ADMIN: address = @0xAA;

    public struct HERO_TEST has drop {}

    fun init(otw: HERO_TEST, ctx: &mut TxContext) {
        package::claim_and_keep(otw, ctx);
    }

    #[test, expected_failure(abort_code = hero::EWrongPublisher)]
    fun test_publisher_cannot_mint_hero_with_wrong_publisher_object() {
        let mut ts = ts::begin(ADMIN);

        assert_eq!(ts::has_most_recent_for_address<Publisher>(ADMIN), false);

        init(HERO_TEST {}, ts.ctx());

        ts.next_tx(ADMIN);

        let publisher = ts.take_from_sender<Publisher>();

        let _hero = hero::create_hero(&publisher, b"Hero 1".to_string(), ts.ctx());

        abort (1337)
    }
}
