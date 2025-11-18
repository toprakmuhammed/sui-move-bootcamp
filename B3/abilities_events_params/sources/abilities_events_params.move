module abilities_events_params::abilities_events_params;
use std::string::String;
use sui::event;
use std::option::Option;
use sui::derived_object_tests::Registry;
use sui::test_scenario::sender;

//Error Codes
const EMedalOfHonorNotAvailable: u64 = 111;

// Structs

//Task 6: Medals adında bir field ekleyin.
//Medals fieldının tipi vector<Medal> olsun.

public struct Hero has key {
    id: UID, // required
    name: String,
    medals: vector<Medal>,
}
//Task 1
//"Hero registry" adında bir obje tutucu oluşturun
//Bu objede "id" ve "heroes" fieldları olsun.
//Heroes fieldının tipi vector<ID> olsun.

public struct HeroRegistry has key {
    id: UID,
    heroes: vector<ID>,
}

//Task 2
//MedalStorage adında bir obje tutucu oluşturun.
//Fieldlar: id, medals
//Medals fieldının tipi vector<Medal> olsun.

public struct MedalStorage has key {
    id: UID,
    medals: vector<Medal>,
}

//Task 3
//Medal adında bir obje oluşturun.
//Fieldlar: id, name

public struct Medal has key, store {
    id: UID,
    name: String,
}

//Eventler sadece copy ve drop yeteneklerine sahip olabilirler.
//Task 4
//HeroMinted adında bir event struct oluşturun.
//Fieldlar: hero_id : ID, owner: address
//Bu eventi tanımlayın.

public struct HeroMinted has copy, drop {
    hero_id: ID,
    owner: address,
}

// Module Initializer
fun init(ctx: &mut TxContext) {
    //Init, ağa deploy edildikten sonra 1 kere çalışır ve bir daha çağrılamaz.
    //Task 5
    //HeroRegistry ve MedalStorage objelerini oluşturun ve bunları shared yapın.
    //hint: Boş vektörü şu şekilde oluşturabilirsiniz: (vector[]);

    let hero_registry = HeroRegistry {
        id: object::new(ctx),
        heroes: vector::empty(),
    };
    let medal_storage = MedalStorage {
        id: object::new(ctx),
        medals: vector[],
    };
    
    transfer::share_object(hero_registry);
    transfer::share_object(medal_storage);

}

public fun mint_hero(name: String, ctx: &mut TxContext, registry: &mut HeroRegistry): Hero {
    let freshHero = Hero {
        id: object::new(ctx), // creates a new UID
        name,
        medals: vector[]
    };
    //Task 7: Bu oluşturulan heroları registry e kaydet.
    //vector::push_back(registry.heroes, object::id(&freshHero)); yerine daha temizini yazalım:
    registry.heroes.push_back(object::id(&freshHero));
    //Burada yaptığımız şey: HeroRegistry objesini shared olarak ödünç alıyoruz ve yeni oluşturulan heronun ID'sini heroes vektörüne ekliyoruz.
    //abilities_events_params şu anlama gelir: modülün adı
    //mint hero'ya HeroRegistry parametresi eklemek istiyoruz birinci gizli task buydu. İkincisi ise freshHero'yu registry'e eklemek.


    //Task 8: HeroMinted eventini emit et.
    event::emit(HeroMinted {
        hero_id: object::id(&freshHero),
        owner: ctx.sender(),
    });
//Burada yaptığımız şey: HeroMinted eventini emit etmek ve böylece dış dünyaya yeni bir hero oluşturulduğunu bildirmek.

    freshHero
}

public fun mint_and_keep_hero(name: String, ctx: &mut TxContext, registry: &mut HeroRegistry) {
    let hero = mint_hero(name, ctx, registry);
    transfer::transfer(hero, ctx.sender());
}

//Task 9: yeni bir fonksiyon oluştur "create_medal"
//9.1 Bu fonksiyon yeni bir madalya oluşturup MedalStorage objesine eklesin.
public fun create_medal(medal_name: String, ctx: &mut TxContext, storage: &mut MedalStorage) {
    let new_medal = Medal {
        id: object::new(ctx),
        name: medal_name,
    };
    storage.medals.push_back(new_medal);
}
//Task 10: Yeni bir fonksiyon oluştur "award_medal"
//10.1 Bu fonksiyon Medal Storage'dan medalı alıp heroya eklesin.
public fun award_medal(name: String, hero: &mut Hero, storage: &mut MedalStorage) {
    let medalOption: Option<Medal> = get_medal(name, storage);

    assert!(medalOption.is_some(), EMedalOfHonorNotAvailable);

    let medal = medalOption.destroy_some<Medal>();

    hero.medals.push_back(medal);
}

public (package) fun get_medal(name: String, storage: &mut MedalStorage): Option<Medal> {
    let mut i = 0;
    while (i < storage.medals.length()) {
       if (storage.medals[i].name == name) {
            let extractedMedal = vector::remove(&mut storage.medals, i);
            // Remove the medal from storage
            return option::some(extractedMedal)
        };
        i = i + 1;
    };
    option::none<Medal>()
}

/////// Tests ///////

#[test_only]
use sui::test_scenario as ts;
#[test_only]
use sui::test_scenario::{take_shared, return_shared};
#[test_only]
use sui::test_utils::{destroy};
#[test_only]
use std::unit_test::assert_eq;

//--------------------------------------------------------------
//  Test 1: Hero Creation
//--------------------------------------------------------------
//  Objective: Verify the correct creation of a Hero object.
//  Tasks:
//      1. Complete the test by calling the `mint_hero` function with a hero name.
//      2. Assert that the created Hero's name matches the provided name.
//      3. Properly clean up the created Hero object using `destroy`.
//--------------------------------------------------------------
#[test]
fun test_hero_creation() {
    let mut test = ts::begin(@USER);
    init(test.ctx()); //Burada hero registry ve medal storage oluşturulmuştu.
    test.next_tx(@USER); //Bu işlemi tamamla, yeni transaction'a geç diyoruz ve diğer transaction'ı bu adres yapacak diye belirtiyoruz.

    let mut registry = take_shared<HeroRegistry>(&test);
    
    //Get hero Registry

    let hero = mint_hero(b"Flash".to_string(), test.ctx(), &mut registry );
    assert_eq!(hero.name, b"Flash".to_string());

    //Task 7: Hero registry içindeki heroes vektörünün uzunluğu artmış mı kontrol et
    //Bunu assert! ile değil de assert_eq! ile yap.

    assert_eq!(registry.heroes.length(), 1);


    return_shared(registry);
    destroy(hero);
    test.end();
}

//--------------------------------------------------------------
//  Test 2: Event Emission
//--------------------------------------------------------------
//  Objective: Implement event emission during hero creation and verify its correctness.
//  Tasks:
//      1. Define a `HeroMinted` event struct with appropriate fields (e.g., hero ID, owner address).  Remember to add `copy, drop` abilities!
//      2. Emit the `HeroMinted` event within the `mint_hero` function after creating the Hero.
//      3. In this test, capture emitted events using `event::events_by_type<HeroMinted>()`.
//      4. Assert that the number of emitted `HeroMinted` events is 1.
//      5. Assert that the `owner` field of the emitted event matches the expected address (e.g., @USER).
//--------------------------------------------------------------
#[test]
fun test_event_thrown() {
// Task 8: Bir senaryo başlat, 
    let mut test = ts::begin(@USER); //ts 112. satırdan geliyor.
// init fonksiyonunu çağır, 
    init(test.ctx());
// diğer tx'e geç, hero oluştur, 
    test.next_tx(@USER);
//bir tane daha hero oluştur, hero registry'i kontrol et. Bu adımda mecburen registry oluşturulacak.

    let mut registry = take_shared<HeroRegistry>(&test);

    let hero1 = mint_hero(b"Hero1".to_string(), test.ctx(), &mut registry);
    let hero2 = mint_hero(b"Hero2".to_string(), test.ctx(), &mut registry);
// event::events_by_type<HeroMinted>() fonksiyonunu kullanarak eventlenen emitleri al.
// Bu eventleri bir değişkene ata. 
// Event değişkeninin uzunluğunun 2 olduğundan emin ol.

    let events = event::events_by_type<HeroMinted>();
    assert_eq!(events.length(), 2);
    assert_eq!(events[0].owner, @USER);
    assert_eq!(events[1].owner, @USER);

// Temizlik yap ve senaryonu bitir.
    return_shared(registry);
    destroy(hero1);

    //Destroy yerine let hero1 {id, .. } = hero1; object::delete(id); şeklinde de yapabilirdik. Bu metodun adı "destructuring" idi.
    destroy(hero2);
    test.end();
}




//--------------------------------------------------------------
//  Test 3: Medal Awarding
//--------------------------------------------------------------
//  Objective: Implement medal awarding functionality to heroes and verify its effects.
//  Tasks:
//      1. Define a `Medal` struct with appropriate fields (e.g., medal ID, medal name). Remember to add `key, store` abilities!
//      2. Add a `medals: vector<Medal>` field to the `Hero` struct to store the medals a hero has earned.
//      3. Create functions to award medals to heroes, e.g., `award_medal_of_honor(hero: &mut Hero)`.
//      4. In this test, mint a hero.
//      5. Award a specific medal (e.g., Medal of Honor) to the hero using your `award_medal_of_honor` function.
//      6. Assert that the hero's `medals` vector now contains the awarded medal.
//      7. Consider creating a shared `MedalStorage` object to manage the available medals.
//--------------------------------------------------------------
#[test]
fun test_medal_award(
    
) {
        //Task 11: 
    // 1. Senaryo oluştur.
    let mut test = ts::begin(@USER);

    // 2. init fonksiyonunu çağır
    init(test.ctx());

    // 3. diğer tx'e geç ve yeni hero oluştur.
    test.next_tx(@USER);

    // 4. registry ve medal starage'ı al.
    let mut registry = take_shared<HeroRegistry>(&test);
    let mut storage = take_shared<MedalStorage>(&test);

    let mut hero = mint_hero(b"ruro".to_string(), test.ctx(), &mut registry);


    // 5. create_medal fonksiyonunu çağır.
    create_medal(b"gold".to_string(), test.ctx(), &mut storage);
    // 6. medalStorage'ın uzunluğunu kontrol et.
    assert_eq!(storage.medals.length(), 1);
    // 7. award_medal'ı çağır.
    award_medal(b"gold".to_string(), &mut hero, &mut storage);
    // 8. hero'nun medals uzunluğunu kontrol et. 
    assert_eq!(storage.medals.length(), 0);
    assert_eq!(hero.medals.length(), 1);
    // 9. Temizlik.
    // 9.1. Registry'i return et.
    return_shared(registry);
    // 9.2. Storage'ı return et.
    return_shared(storage);
    // 9.3. Hero'yu destroy et.
    destroy(hero);
    // 10. Testi bitir.
    test.end();

}
