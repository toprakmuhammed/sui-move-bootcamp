import { Ed25519Keypair } from "@mysten/sui/keypairs/ed25519";
import { mintHero, newAdmin } from "../helper/hero";
import { SuiTransactionBlockResponse } from "@mysten/sui/client";
import { getSigner } from "../helper/getSigner";
import { transferSUI } from "../helper/transferSUI";

describe("Cap Ownership", () => {
  const admin2 = Ed25519Keypair.generate();

  it("should work for owned admin cap", async () => {
    const signer = getSigner({ secretKey: process.env.ADMIN_SECRET_KEY! });
    const result = await mintHero("test", signer, process.env.ADMIN_CAP_ID!);
    expect((result as SuiTransactionBlockResponse).effects?.status.status).toBe(
      "success"
    );
  });

  it("should fail for not owned admin cap", async () => {
    const result = await mintHero("test", admin2, process.env.ADMIN_CAP_ID!);

    expect((result as Error).message).toContain(
      "Transaction was not signed by the correct sender"
    );
  });

  it("should work after minting and transferring a new admin cap", async () => {
    const signer = getSigner({ secretKey: process.env.ADMIN_SECRET_KEY! });
    const suiResult = await transferSUI(
      500_000_000,
      signer,
      admin2.toSuiAddress()
    );
    expect(suiResult.effects?.status.status).toBe("success");

    const result = await newAdmin(signer, admin2.toSuiAddress());
    expect(result.effects?.status.status).toBe("success");

    const newAdminCap = result.effects?.created![0];
    expect(newAdminCap).toBeDefined();

    const transferResult = await mintHero(
      "test",
      admin2,
      newAdminCap!.reference.objectId
    );
    expect(
      (transferResult as SuiTransactionBlockResponse).effects?.status.status
    ).toBe("success");
  });
});
