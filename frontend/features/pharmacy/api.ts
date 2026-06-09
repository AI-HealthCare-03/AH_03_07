import { apiFetch } from "@/lib/api/client";

export interface Pharmacy {
  id: number;
  name: string;
  address: string;
  phone: string;
  hours?: string;
  is24h?: boolean;
  isNight?: boolean;
  open?: boolean;
  distance?: string;
  lat?: number;
  lng?: number;
}

export interface GetPharmaciesParams {
  lat?: number;
  lng?: number;
  keyword?: string;
}

export async function getPharmacies(params?: GetPharmaciesParams): Promise<Pharmacy[]> {
  const query = new URLSearchParams();
  if (params?.lat !== undefined) query.set("lat", String(params.lat));
  if (params?.lng !== undefined) query.set("lng", String(params.lng));
  if (params?.keyword) query.set("keyword", params.keyword);
  const qs = query.toString();
  const res = await apiFetch<{ items?: Pharmacy[] } | Pharmacy[]>(
    `/v1/pharmacies${qs ? `?${qs}` : ""}`
  );
  return Array.isArray(res) ? res : (res.items ?? []);
}

export async function getNearbyPharmacies(latitude: number, longitude: number): Promise<Pharmacy[]> {
  const res = await apiFetch<{ items?: Pharmacy[] } | Pharmacy[]>(
    `/v1/pharmacies/nearby?latitude=${latitude}&longitude=${longitude}&radius_km=5.0`
  );
  return Array.isArray(res) ? res : (res.items ?? []);
}
