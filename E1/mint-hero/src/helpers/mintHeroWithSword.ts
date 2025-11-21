import { SuiTransactionBlockResponse } from "@mysten/sui/client";
import { Transaction } from "@mysten/sui/transactions";
import { suiClient } from "../suiClient";
import { getSigner } from "./getSigner";
import { ENV } from "../env";
import { getAddress } from "./getAddress";

/**
 * Builds, signs, and executes a transaction for:
 * * minting a Hero NFT: use the `package_id::hero::mint_hero` function
 * * minting a Sword NFT: use the `package_id::blacksmith::new_sword` function
 * * attaching the Sword to the Hero: use the `package_id::hero::equip_sword` function
 * * transferring the Hero to the signer
 */
export const mintHeroWithSword =
  async (): Promise<SuiTransactionBlockResponse> => {
    // TASK:
    //1. Transaction'ı initialize et.
    //2. `${ENV.PACKAGE_ID}::hero::mint_hero` targetini çağırıp hero mintle.
    //3. Aynı işlemi blacksmith::new_sword için yap (Unutma bu fonksiyon bir parametre bekler).
    //4. hero::equip_sword ile heroyu equip et.
    //5. hero'yu "getAddress ({ secretKey: ENV.SECRET_KEY })" adresine transfer et.
    //6. suiClient.signAndExecuteTransaction metoduyla tx'i execute et.
    //Bonus: Yukarıdaki işlemdeki option section'una "showEffects, showObjectChanges"ı true olarak ekle."

    
    // Hocanın çözüm
    const tx = new Transaction();

    let hero = tx.moveCall({
      target: `${ENV.PACKAGE_ID}::hero::mint_hero`,
    });
    let sword = tx.moveCall({
      target: `${ENV.PACKAGE_ID}::blacksmith::new_sword`,
      arguments: [tx.pure.u64("10")],
    });

    tx.moveCall({
      target: `${ENV.PACKAGE_ID}::hero::equip_sword`,
      arguments: [hero, sword],
    });
    
    tx.transferObjects([hero], getAddress({ secretKey: ENV.USER_SECRET_KEY }));
    return suiClient.signAndExecuteTransaction({
      transaction: tx,
      signer: getSigner({ secretKey: ENV.USER_SECRET_KEY }),
      options: {
        showEffects: true,
        showObjectChanges: true,
      },
    });
  };
