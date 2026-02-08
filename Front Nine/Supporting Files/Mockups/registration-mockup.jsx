import { useState } from "react";

// Front Nine Design Tokens
const colors = {
  cream: "#FAF8F5",
  white: "#FFFFFF",
  text: "#2C2C2C",
  textLight: "#6B6360",
  sage: "#7D9A78",
  sageDark: "#6A8766",
  tan: "#D4C4B0",
  coral: "#E8A598",
  warmGray: "#A0938A",
  error: "#C4736A",
};

const font = `-apple-system, BlinkMacSystemFont, 'SF Pro Display', 'SF Pro', 'Segoe UI', sans-serif`;

export default function LoginPage() {
  const [mode, setMode] = useState("login"); // login | signup | forgot
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [name, setName] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [focusedField, setFocusedField] = useState(null);

  const canSubmit = mode === "forgot"
    ? email.trim().length > 0
    : mode === "signup"
      ? email.trim().length > 0 && password.length > 0 && name.trim().length > 0
      : email.trim().length > 0 && password.length > 0;

  const buttonLabels = {
    login: "Sign In",
    signup: "Create Account",
    forgot: "Send Reset Link",
  };

  return (
    <div style={{
      fontFamily: font, background: "#E8E4E0",
      minHeight: "100vh", display: "flex", justifyContent: "center",
      alignItems: "flex-start", padding: "20px 16px",
    }}>
      {/* iPhone frame */}
      <div style={{
        width: 375, height: 812, background: colors.cream,
        borderRadius: 40, border: "8px solid #1a1a1a",
        overflow: "hidden", position: "relative",
        boxShadow: "0 25px 50px rgba(0,0,0,0.15)",
        display: "flex", flexDirection: "column",
      }}>
        {/* Dynamic Island */}
        <div style={{
          height: 47, background: colors.cream, flexShrink: 0,
          display: "flex", justifyContent: "center", alignItems: "flex-end", paddingBottom: 8,
        }}>
          <div style={{ width: 120, height: 28, background: "#1a1a1a", borderRadius: 20 }} />
        </div>

        {/* Content */}
        <div style={{
          flex: 1, display: "flex", flexDirection: "column",
          padding: "0 24px", overflow: "hidden",
        }}>

          {/* Top spacing + brand */}
          <div style={{ paddingTop: 48, marginBottom: 40 }}>
            {/* Brand mark */}
            <div style={{
              display: "flex", alignItems: "center", gap: 12,
              marginBottom: 28,
            }}>
              {/* Flag logomark */}
              <div style={{
                width: 40, height: 40, borderRadius: 11,
                background: `linear-gradient(145deg, ${colors.sage}, ${colors.sageDark})`,
                display: "flex", alignItems: "center", justifyContent: "center",
                boxShadow: `0 2px 8px ${colors.sage}33`,
              }}>
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" strokeLinecap="round" strokeLinejoin="round">
                  <path d="M4 15s1-1 4-1 5 2 8 2 4-1 4-1V3s-1 1-4 1-5-2-8-2-4 1-4 1z" fill={`${colors.cream}44`} stroke={colors.cream} strokeWidth="1.8" />
                  <line x1="4" x2="4" y1="22" y2="15" stroke={colors.cream} strokeWidth="1.8" />
                </svg>
              </div>
              <span style={{
                fontSize: 26, fontWeight: 700, color: colors.text,
                letterSpacing: -0.8,
                fontFamily: font,
              }}>
                Front Nine
              </span>
            </div>

            {/* Subtitle */}
            <h1 style={{
              fontSize: 28, fontWeight: 600, color: colors.text,
              margin: 0, letterSpacing: -0.5, lineHeight: 1.1,
            }}>
              {mode === "login" ? "Sign in to your account" : mode === "signup" ? "Create your account" : "Reset your password"}
            </h1>
            <p style={{
              fontSize: 15, color: colors.textLight, margin: "6px 0 0",
              fontWeight: 400, lineHeight: 1.4,
            }}>
              {mode === "login" ? "Pick up where you left off" : mode === "signup" ? "Start ranking your favorite courses" : "We'll send you a reset link"}
            </p>
          </div>

          {/* Form fields */}
          <div style={{ display: "flex", flexDirection: "column", gap: 14 }}>

            {/* Name (signup only) */}
            {mode === "signup" && (
              <div>
                <label style={{
                  fontSize: 13, fontWeight: 600, letterSpacing: 0.5,
                  textTransform: "uppercase", color: colors.textLight,
                  display: "block", marginBottom: 6,
                }}>Name</label>
                <input
                  type="text"
                  placeholder="Your name"
                  value={name}
                  onChange={e => setName(e.target.value)}
                  onFocus={() => setFocusedField("name")}
                  onBlur={() => setFocusedField(null)}
                  style={{
                    width: "100%", boxSizing: "border-box",
                    padding: "13px 14px", fontSize: 17, fontFamily: font,
                    background: colors.white, color: colors.text,
                    border: `1.5px solid ${focusedField === "name" ? colors.sage : colors.tan}`,
                    borderRadius: 12, outline: "none",
                    transition: "border-color 0.2s ease",
                  }}
                />
              </div>
            )}

            {/* Email */}
            <div>
              <label style={{
                fontSize: 13, fontWeight: 600, letterSpacing: 0.5,
                textTransform: "uppercase", color: colors.textLight,
                display: "block", marginBottom: 6,
              }}>Email</label>
              <input
                type="email"
                placeholder="you@email.com"
                value={email}
                onChange={e => setEmail(e.target.value)}
                onFocus={() => setFocusedField("email")}
                onBlur={() => setFocusedField(null)}
                style={{
                  width: "100%", boxSizing: "border-box",
                  padding: "13px 14px", fontSize: 17, fontFamily: font,
                  background: colors.white, color: colors.text,
                  border: `1.5px solid ${focusedField === "email" ? colors.sage : colors.tan}`,
                  borderRadius: 12, outline: "none",
                  transition: "border-color 0.2s ease",
                }}
              />
            </div>

            {/* Password */}
            {mode !== "forgot" && (
              <div>
                <label style={{
                  fontSize: 13, fontWeight: 600, letterSpacing: 0.5,
                  textTransform: "uppercase", color: colors.textLight,
                  display: "block", marginBottom: 6,
                }}>Password</label>
                <div style={{ position: "relative" }}>
                  <input
                    type={showPassword ? "text" : "password"}
                    placeholder={mode === "signup" ? "Create a password" : "Your password"}
                    value={password}
                    onChange={e => setPassword(e.target.value)}
                    onFocus={() => setFocusedField("password")}
                    onBlur={() => setFocusedField(null)}
                    style={{
                      width: "100%", boxSizing: "border-box",
                      padding: "13px 44px 13px 14px", fontSize: 17, fontFamily: font,
                      background: colors.white, color: colors.text,
                      border: `1.5px solid ${focusedField === "password" ? colors.sage : colors.tan}`,
                      borderRadius: 12, outline: "none",
                      transition: "border-color 0.2s ease",
                    }}
                  />
                  <button
                    onClick={() => setShowPassword(!showPassword)}
                    style={{
                      position: "absolute", right: 12, top: "50%", transform: "translateY(-50%)",
                      background: "none", border: "none", cursor: "pointer",
                      color: colors.tan, padding: 4,
                    }}
                  >
                    {showPassword ? (
                      <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                        <path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94" />
                        <path d="M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19" />
                        <line x1="1" y1="1" x2="23" y2="23" />
                      </svg>
                    ) : (
                      <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                        <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z" />
                        <circle cx="12" cy="12" r="3" />
                      </svg>
                    )}
                  </button>
                </div>

                {/* Forgot password link */}
                {mode === "login" && (
                  <button
                    onClick={() => setMode("forgot")}
                    style={{
                      background: "none", border: "none", cursor: "pointer",
                      fontSize: 14, fontFamily: font, color: colors.sage,
                      fontWeight: 500, padding: "8px 0 0", textAlign: "left",
                      display: "block",
                    }}
                  >
                    Forgot password?
                  </button>
                )}
              </div>
            )}
          </div>

          {/* Submit button */}
          <div style={{ marginTop: 28 }}>
            <button
              disabled={!canSubmit}
              style={{
                width: "100%", padding: "16px 24px",
                background: canSubmit ? colors.sage : `${colors.tan}66`,
                color: canSubmit ? colors.white : colors.warmGray,
                border: "none", borderRadius: 14, cursor: canSubmit ? "pointer" : "default",
                fontSize: 17, fontWeight: 600, fontFamily: font,
                transition: "all 0.2s ease",
              }}
              onMouseDown={e => { if (canSubmit) e.currentTarget.style.transform = "scale(0.97)"; }}
              onMouseUp={e => e.currentTarget.style.transform = "scale(1)"}
            >
              {buttonLabels[mode]}
            </button>
          </div>

          {/* Divider */}
          <div style={{
            display: "flex", alignItems: "center", gap: 14,
            margin: "24px 0",
          }}>
            <div style={{ flex: 1, height: 1, background: `${colors.tan}44` }} />
            <span style={{ fontSize: 13, color: colors.tan, fontWeight: 500 }}>or</span>
            <div style={{ flex: 1, height: 1, background: `${colors.tan}44` }} />
          </div>

          {/* Social login buttons */}
          <div style={{ display: "flex", flexDirection: "column", gap: 10 }}>
            {/* Apple */}
            <button style={{
              width: "100%", padding: "14px 24px",
              background: colors.text, color: colors.white,
              border: "none", borderRadius: 14, cursor: "pointer",
              fontSize: 16, fontWeight: 600, fontFamily: font,
              display: "flex", alignItems: "center", justifyContent: "center", gap: 10,
              transition: "all 0.2s ease",
            }}
            onMouseDown={e => e.currentTarget.style.transform = "scale(0.97)"}
            onMouseUp={e => e.currentTarget.style.transform = "scale(1)"}
            >
              <svg width="18" height="18" viewBox="0 0 24 24" fill="white">
                <path d="M17.05 20.28c-.98.95-2.05.88-3.08.4-1.09-.5-2.08-.48-3.24 0-1.44.62-2.2.44-3.06-.4C2.79 15.25 3.51 7.59 9.05 7.31c1.35.07 2.29.74 3.08.8 1.18-.24 2.31-.93 3.57-.84 1.51.12 2.65.72 3.4 1.8-3.12 1.87-2.38 5.98.48 7.13-.57 1.5-1.31 2.99-2.54 4.09zM12.03 7.25c-.15-2.23 1.66-4.07 3.74-4.25.32 2.32-1.55 4.23-3.74 4.25z"/>
              </svg>
              Continue with Apple
            </button>

            {/* Google */}
            <button style={{
              width: "100%", padding: "14px 24px",
              background: colors.white, color: colors.text,
              border: `1.5px solid ${colors.tan}66`, borderRadius: 14, cursor: "pointer",
              fontSize: 16, fontWeight: 600, fontFamily: font,
              display: "flex", alignItems: "center", justifyContent: "center", gap: 10,
              transition: "all 0.2s ease",
            }}
            onMouseDown={e => e.currentTarget.style.transform = "scale(0.97)"}
            onMouseUp={e => e.currentTarget.style.transform = "scale(1)"}
            >
              <svg width="18" height="18" viewBox="0 0 24 24">
                <path d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92a5.06 5.06 0 0 1-2.2 3.32v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.1z" fill="#4285F4"/>
                <path d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" fill="#34A853"/>
                <path d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18A10.96 10.96 0 0 0 1 12c0 1.77.42 3.45 1.18 4.93l3.66-2.84z" fill="#FBBC05"/>
                <path d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z" fill="#EA4335"/>
              </svg>
              Continue with Google
            </button>
          </div>

          {/* Spacer */}
          <div style={{ flex: 1 }} />

          {/* Mode toggle */}
          <div style={{
            textAlign: "center", paddingBottom: 24,
          }}>
            {mode === "forgot" ? (
              <button
                onClick={() => setMode("login")}
                style={{
                  background: "none", border: "none", cursor: "pointer",
                  fontSize: 15, fontFamily: font, color: colors.textLight,
                }}
              >
                Back to <span style={{ color: colors.sage, fontWeight: 600 }}>Sign In</span>
              </button>
            ) : (
              <button
                onClick={() => setMode(mode === "login" ? "signup" : "login")}
                style={{
                  background: "none", border: "none", cursor: "pointer",
                  fontSize: 15, fontFamily: font, color: colors.textLight,
                }}
              >
                {mode === "login" ? "Don't have an account? " : "Already have an account? "}
                <span style={{ color: colors.sage, fontWeight: 600 }}>
                  {mode === "login" ? "Sign Up" : "Sign In"}
                </span>
              </button>
            )}
          </div>
        </div>

        {/* Home indicator */}
        <div style={{
          position: "absolute", bottom: 8, left: "50%", transform: "translateX(-50%)",
          width: 134, height: 5, background: "#1a1a1a20", borderRadius: 3,
        }} />
      </div>
    </div>
  );
}
