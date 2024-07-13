export interface Mapping {
  key: string;
  values: string[]; // JSON string that will be parsed to an array
}

export interface DatabaseRow {
  key: string;
  values: string; // Still a string here because that's how it's stored in the DB
}
