// 약품 인식 API (REQ-PILL-004)
import { apiFetch } from "@/lib/api/client";

export interface PillCandidate {
  drug_name: string;
  ingredient?: string;
  category?: string;
  confidence: number;
}

export interface PillRecognition {
  id: number;
  drug_name?: string;
  confidence?: number;
  created_at?: string;
}

export async function recognizePill(file: File): Promise<PillCandidate[]> {
  const body = new FormData();
  body.append("file", file);
  const res = await apiFetch<{ candidates?: PillCandidate[] } | PillCandidate[]>(
    "/v1/pills/recognize",
    { method: "POST", body }
  );
  return Array.isArray(res) ? res : (res.candidates ?? []);
}

export async function getPillRecognitions(): Promise<PillRecognition[]> {
  const res = await apiFetch<
    { items?: PillRecognition[] } | PillRecognition[]
  >("/v1/pills/recognitions");
  return Array.isArray(res) ? res : (res.items ?? []);
}

export interface DrugInfo {
  item_name: string;
  entp_name?: string;
  item_seq?: string;
  efcy_qesitm?: string;
  use_method_qesitm?: string;
  atpn_warn_qesitm?: string;
  atpn_qesitm?: string;
  intrc_qesitm?: string;
  se_qesitm?: string;
  deposit_method_qesitm?: string;
  item_image?: string;
}

export async function searchDrugReferences(drugName: string): Promise<DrugInfo[]> {
  const res = await apiFetch<{ drugs?: DrugInfo[] }>(
    `/v1/drug-references?drug_name=${encodeURIComponent(drugName)}`
  );
  return res.drugs ?? [];
}

/** @deprecated use getPillRecognitions */
export const getRecognitions = getPillRecognitions;
