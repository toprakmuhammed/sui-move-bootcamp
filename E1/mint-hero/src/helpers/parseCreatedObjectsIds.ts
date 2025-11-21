import { SuiObjectChange, SuiObjectChangeCreated } from "@mysten/sui/client";
import { ENV } from "../env";

interface Args {
  objectChanges: SuiObjectChange[];
}

interface Response {
  swordsIds: string[];
  heroesIds: string[];
}

/**
 * Parses the provided SuiObjectChange[].
 * Extracts the IDs of the created Heroes and Swords NFTs, filtering by objectType.
 */
export const parseCreatedObjectsIds = ({ objectChanges }: Args): Response => {
  // TODO: Implement this function
  const createdObjects = objectChanges.filter(
    ({ type }) => type === "created"
  ) as SuiObjectChangeCreated[];
  const swords = createdObjects.filter(
    ({ objectType }) => objectType === `${ENV.PACKAGE_ID}::blacksmith::Sword`
  );

  const heros = createdObjects.filter(
    ({ objectType }) => objectType === `${ENV.PACKAGE_ID}::hero::Hero`
  );

  return {
    swordsIds: swords.map(({ objectId }) => objectId),
    heroesIds: heros.map(({ objectId }) => objectId),
  };
};
