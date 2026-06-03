import { redirect } from "next/navigation";

// 진입점 → 로그인으로 (인증 후 /home)
export default function RootPage() {
  redirect("/login");
}
