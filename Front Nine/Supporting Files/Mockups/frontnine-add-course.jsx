import { useState, useEffect, useRef } from "react";

const MOCK_COURSES = [
  { id: 1, name: "Bethpage Black Course", city: "Farmingdale", state: "NY", par: 71, holes: 18, rating: 77.5, slope: 155, type: "Public" },
  { id: 2, name: "Bethpage Red Course", city: "Farmingdale", state: "NY", par: 68, holes: 18, rating: 73.2, slope: 141, type: "Public" },
  { id: 3, name: "Bethpage Blue Course", city: "Farmingdale", state: "NY", par: 72, holes: 18, rating: 75.0, slope: 148, type: "Public" },
  { id: 4, name: "Shinnecock Hills Golf Club", city: "Southampton", state: "NY", par: 70, holes: 18, rating: 76.4, slope: 147, type: "Private" },
  { id: 5, name: "Pebble Beach Golf Links", city: "Pebble Beach", state: "CA", par: 72, holes: 18, rating: 75.5, slope: 145, type: "Public" },
  { id: 6, name: "Augusta National Golf Club", city: "Augusta", state: "GA", par: 72, holes: 18, rating: 76.2, slope: 148, type: "Private" },
  { id: 7, name: "Pine Valley Golf Club", city: "Pine Valley", state: "NJ", par: 70, holes: 18, rating: 74.5, slope: 153, type: "Private" },
  { id: 8, name: "Pinehurst No. 2", city: "Pinehurst", state: "NC", par: 72, holes: 18, rating: 75.3, slope: 141, type: "Public" },
  { id: 9, name: "TPC Sawgrass (Stadium)", city: "Ponte Vedra Beach", state: "FL", par: 72, holes: 18, rating: 76.8, slope: 155, type: "Public" },
  { id: 10, name: "Bandon Dunes", city: "Bandon", state: "OR", par: 72, holes: 18, rating: 74.1, slope: 142, type: "Public" },
  { id: 11, name: "Winged Foot Golf Club (West)", city: "Mamaroneck", state: "NY", par: 72, holes: 18, rating: 76.0, slope: 150, type: "Private" },
  { id: 12, name: "The Country Club (Composite)", city: "Brookline", state: "MA", par: 71, holes: 18, rating: 74.8, slope: 143, type: "Private" },
];

// Front Nine Design Tokens
const colors = {
  cream: "#FAF8F5",
  white: "#FFFFFF",
  text: "#2C2C2C",
  textLight: "#6B6360",
  sage: "#7D9A78",
  tan: "#D4C4B0",
  coral: "#E8A598",
  warmGray: "#A0938A",
};

const font = `-apple-system, BlinkMacSystemFont, 'SF Pro Display', 'SF Pro', 'Segoe UI', sans-serif`;

const TypePill = ({ type }) => {
  const isPrivate = type === "Private";
  return (
    <span style={{
      fontSize: 11, fontWeight: 600, letterSpacing: 0.5,
      padding: "3px 9px", borderRadius: 8,
      background: isPrivate ? "rgba(160, 147, 138, 0.12)" : "rgba(125, 154, 120, 0.12)",
      color: isPrivate ? colors.warmGray : colors.sage,
      textTransform: "uppercase", whiteSpace: "nowrap",
    }}>{type}</span>
  );
};

const SearchIcon = ({ color }) => (
  <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke={color || colors.textLight} strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round">
    <circle cx="11" cy="11" r="8" /><path d="m21 21-4.35-4.35" />
  </svg>
);

const ChevronRight = () => (
  <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke={colors.tan} strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
    <path d="m9 18 6-6-6-6" />
  </svg>
);

const ChevronLeft = () => (
  <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke={colors.sage} strokeWidth="2.8" strokeLinecap="round" strokeLinejoin="round">
    <path d="m15 18-6-6 6-6" />
  </svg>
);

const MapPinIcon = () => (
  <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round">
    <path d="M20 10c0 6-8 12-8 12s-8-6-8-12a8 8 0 0 1 16 0Z" /><circle cx="12" cy="10" r="3" />
  </svg>
);

const CloseIcon = () => (
  <svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round">
    <path d="M18 6 6 18" /><path d="m6 6 12 12" />
  </svg>
);

const CheckIcon = () => (
  <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
    <path d="M20 6 9 17l-5-5" />
  </svg>
);

const LocationIcon = () => (
  <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
    <polygon points="3 11 22 2 13 21 11 13 3 11" />
  </svg>
);

const EditIcon = () => (
  <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
    <path d="M17 3a2.85 2.85 0 1 1 4 4L7.5 20.5 2 22l1.5-5.5Z" />
  </svg>
);

const FlagIcon = () => (
  <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
    <path d="M4 15s1-1 4-1 5 2 8 2 4-1 4-1V3s-1 1-4 1-5-2-8-2-4 1-4 1z" /><line x1="4" x2="4" y1="22" y2="15" />
  </svg>
);

export default function AddCoursePage() {
  const [query, setQuery] = useState("");
  const [results, setResults] = useState([]);
  const [searching, setSearching] = useState(false);
  const [selectedCourse, setSelectedCourse] = useState(null);
  const [showDetail, setShowDetail] = useState(false);
  const [added, setAdded] = useState(false);
  const [recentlyAdded, setRecentlyAdded] = useState([]);
  const [recentSearches, setRecentSearches] = useState(["Bethpage", "Pebble Beach", "Pinehurst"]);
  const inputRef = useRef(null);

  useEffect(() => {
    if (!query.trim()) { setResults([]); setSearching(false); return; }
    setSearching(true);
    const timer = setTimeout(() => {
      const q = query.toLowerCase();
      const filtered = MOCK_COURSES.filter(c =>
        c.name.toLowerCase().includes(q) ||
        c.city.toLowerCase().includes(q) ||
        c.state.toLowerCase().includes(q)
      );
      setResults(filtered);
      setSearching(false);
    }, 400);
    return () => clearTimeout(timer);
  }, [query]);

  const handleSelect = (course) => {
    setSelectedCourse(course);
    setShowDetail(true);
    setAdded(false);
  };

  const handleAdd = () => {
    setAdded(true);
    setRecentlyAdded(prev => [selectedCourse.id, ...prev]);
    if (query.trim() && !recentSearches.includes(query.trim())) {
      setRecentSearches(prev => [query.trim(), ...prev].slice(0, 4));
    }
    setTimeout(() => {
      setShowDetail(false);
      setSelectedCourse(null);
      setQuery("");
      setAdded(false);
    }, 1600);
  };

  const handleBack = () => {
    setShowDetail(false);
    setSelectedCourse(null);
    setAdded(false);
  };

  return (
    <div style={{
      fontFamily: font, background: "#E8E4E0",
      minHeight: "100vh", display: "flex", justifyContent: "center",
      alignItems: "flex-start", padding: "20px 16px",
    }}>
      {/* iPhone frame */}
      <div style={{
        width: 375, minHeight: 812, background: colors.cream,
        borderRadius: 40, border: "8px solid #1a1a1a",
        overflow: "hidden", position: "relative",
        boxShadow: "0 25px 50px rgba(0,0,0,0.15)",
      }}>
        {/* Dynamic Island */}
        <div style={{
          height: 47, background: colors.cream,
          display: "flex", justifyContent: "center", alignItems: "flex-end", paddingBottom: 8,
        }}>
          <div style={{ width: 120, height: 28, background: "#1a1a1a", borderRadius: 20 }} />
        </div>

        {/* Content */}
        <div style={{ padding: "0 0 40px", position: "relative" }}>

          {/* ===== DETAIL SHEET ===== */}
          {showDetail && selectedCourse && (
            <div style={{
              position: "absolute", top: 0, left: 0, right: 0, bottom: 0,
              zIndex: 100, background: colors.cream, minHeight: 757,
              animation: "fnSlideUp 0.35s cubic-bezier(0.32, 0.72, 0, 1)",
            }}>
              <style>{`
                @keyframes fnSlideUp {
                  from { transform: translateY(100%); opacity: 0.6; }
                  to { transform: translateY(0); opacity: 1; }
                }
                @keyframes fnFadeUp {
                  from { transform: translateY(10px); opacity: 0; }
                  to { transform: translateY(0); opacity: 1; }
                }
                @keyframes fnPop {
                  0% { transform: scale(0.5); opacity: 0; }
                  60% { transform: scale(1.12); }
                  100% { transform: scale(1); opacity: 1; }
                }
              `}</style>

              {/* Detail nav */}
              <div style={{ padding: "12px 20px 0" }}>
                <button onClick={handleBack} style={{
                  background: "none", border: "none", cursor: "pointer",
                  color: colors.sage, fontSize: 16, fontWeight: 500, fontFamily: font,
                  display: "flex", alignItems: "center", gap: 4, padding: "8px 0",
                }}>
                  <ChevronLeft /> Search
                </button>
              </div>

              {/* Course name & location */}
              <div style={{ padding: "20px 20px 24px" }}>
                <h2 style={{
                  fontSize: 28, fontWeight: 600, color: colors.text,
                  margin: 0, letterSpacing: -0.5, lineHeight: 1.15,
                }}>{selectedCourse.name}</h2>
                <div style={{
                  fontSize: 15, color: colors.textLight, marginTop: 6,
                  display: "flex", alignItems: "center", gap: 5,
                }}>
                  <MapPinIcon />
                  {selectedCourse.city}, {selectedCourse.state}
                  <span style={{ margin: "0 4px", color: colors.tan }}>·</span>
                  <TypePill type={selectedCourse.type} />
                </div>
              </div>

              {/* Stats */}
              <div style={{
                margin: "0 20px 24px",
                display: "grid", gridTemplateColumns: "1fr 1fr", gap: 12,
              }}>
                {[
                  { label: "Par", value: selectedCourse.par },
                  { label: "Holes", value: selectedCourse.holes },
                  { label: "Rating", value: selectedCourse.rating },
                  { label: "Slope", value: selectedCourse.slope },
                ].map((stat, i) => (
                  <div key={i} style={{
                    background: colors.white, borderRadius: 14,
                    padding: "16px 18px",
                    border: `1.5px solid ${colors.tan}33`,
                    animation: `fnFadeUp 0.4s cubic-bezier(0.32, 0.72, 0, 1) ${0.08 + i * 0.05}s both`,
                  }}>
                    <div style={{
                      fontSize: 13, fontWeight: 600, letterSpacing: 0.5,
                      textTransform: "uppercase", color: colors.textLight, marginBottom: 4,
                    }}>{stat.label}</div>
                    <div style={{
                      fontSize: 28, fontWeight: 300, color: colors.text,
                      letterSpacing: -0.5,
                    }}>{stat.value}</div>
                  </div>
                ))}
              </div>

              {/* Divider */}
              <div style={{ margin: "0 20px 24px", height: 1, background: colors.tan, opacity: 0.3 }} />

              {/* Add to rankings button */}
              <div style={{
                margin: "0 20px",
                animation: "fnFadeUp 0.4s cubic-bezier(0.32, 0.72, 0, 1) 0.3s both",
              }}>
                {!added ? (
                  <button onClick={handleAdd} style={{
                    width: "100%", padding: "16px 24px",
                    background: colors.sage, color: colors.white,
                    border: "none", borderRadius: 14, cursor: "pointer",
                    fontSize: 17, fontWeight: 600, fontFamily: font,
                    display: "flex", alignItems: "center", justifyContent: "center", gap: 8,
                    transition: "all 0.2s ease",
                  }}
                  onMouseDown={e => e.currentTarget.style.transform = "scale(0.97)"}
                  onMouseUp={e => e.currentTarget.style.transform = "scale(1)"}
                  >
                    Add & Rate This Course
                  </button>
                ) : (
                  <div style={{
                    width: "100%", padding: "16px 24px",
                    background: colors.sage, color: colors.white,
                    borderRadius: 14, fontSize: 17, fontWeight: 600,
                    display: "flex", alignItems: "center", justifyContent: "center", gap: 8,
                    animation: "fnPop 0.4s cubic-bezier(0.32, 0.72, 0, 1)",
                  }}>
                    <CheckIcon /> Added!
                  </div>
                )}
              </div>
            </div>
          )}

          {/* ===== MAIN CONTENT ===== */}

          {/* Header */}
          <div style={{ padding: "8px 20px 0", display: "flex", justifyContent: "space-between", alignItems: "center" }}>
            <button style={{
              background: "none", border: "none", cursor: "pointer",
              color: colors.sage, fontSize: 16, fontWeight: 500, fontFamily: font,
              padding: "8px 0", display: "flex", alignItems: "center", gap: 4,
            }}>
              <ChevronLeft /> Cancel
            </button>
          </div>

          {/* Title */}
          <div style={{ padding: "16px 20px 24px" }}>
            <h1 style={{
              fontSize: 28, fontWeight: 600, color: colors.text,
              margin: 0, letterSpacing: -0.5,
            }}>
              Add Course
            </h1>
          </div>

          {/* Search bar */}
          <div style={{ padding: "0 20px 16px" }}>
            <div style={{
              display: "flex", alignItems: "center", gap: 10,
              background: colors.white, borderRadius: 12, padding: "0 14px",
              border: `1.5px solid ${query ? colors.sage : colors.tan}`,
              transition: "all 0.25s ease",
            }}>
              <span style={{ color: query ? colors.sage : colors.tan, transition: "color 0.2s", flexShrink: 0 }}>
                <SearchIcon color={query ? colors.sage : colors.tan} />
              </span>
              <input
                ref={inputRef}
                type="text"
                placeholder="Search by name, city, or state..."
                value={query}
                onChange={e => setQuery(e.target.value)}
                style={{
                  flex: 1, border: "none", outline: "none",
                  fontSize: 17, fontFamily: font, padding: "13px 0",
                  color: colors.text, background: "transparent",
                  fontWeight: 400,
                }}
              />
              {query && (
                <button onClick={() => { setQuery(""); inputRef.current?.focus(); }} style={{
                  background: colors.tan, border: "none", cursor: "pointer",
                  borderRadius: 50, width: 20, height: 20, padding: 0,
                  display: "flex", alignItems: "center", justifyContent: "center",
                  flexShrink: 0, color: colors.white,
                }}>
                  <CloseIcon />
                </button>
              )}
            </div>
          </div>

          {/* ===== SEARCH RESULTS ===== */}
          {query && (
            <div style={{ padding: "0 20px" }}>
              {searching ? (
                <div style={{ padding: "48px 0", textAlign: "center" }}>
                  <div style={{
                    width: 24, height: 24,
                    border: `2.5px solid ${colors.tan}44`,
                    borderTopColor: colors.sage, borderRadius: "50%",
                    margin: "0 auto 14px",
                    animation: "fnSpin 0.8s linear infinite",
                  }} />
                  <style>{`@keyframes fnSpin { to { transform: rotate(360deg); } }`}</style>
                  <div style={{ fontSize: 15, color: colors.textLight }}>Searching courses...</div>
                </div>
              ) : results.length > 0 ? (
                <>
                  <div style={{
                    fontSize: 13, fontWeight: 600, letterSpacing: 0.5,
                    textTransform: "uppercase", color: colors.textLight, marginBottom: 12,
                  }}>
                    {results.length} {results.length === 1 ? "result" : "results"}
                  </div>
                  <div>
                    {results.map((course, i) => (
                      <div
                        key={course.id}
                        onClick={() => handleSelect(course)}
                        style={{
                          padding: "14px 0", cursor: "pointer",
                          display: "flex", alignItems: "center", gap: 14,
                          borderBottom: i < results.length - 1 ? `1px solid ${colors.tan}33` : "none",
                        }}
                      >
                        {/* Icon or checkmark */}
                        <div style={{
                          width: 36, height: 36, borderRadius: 10,
                          display: "flex", alignItems: "center", justifyContent: "center",
                          flexShrink: 0,
                          ...(recentlyAdded.includes(course.id)
                            ? { background: colors.sage, color: colors.white }
                            : { background: `${colors.tan}22`, color: colors.tan }
                          ),
                        }}>
                          {recentlyAdded.includes(course.id) ? <CheckIcon /> : <FlagIcon />}
                        </div>

                        {/* Course info */}
                        <div style={{ flex: 1, minWidth: 0 }}>
                          <div style={{
                            fontSize: 17, fontWeight: 500, color: colors.text,
                            marginBottom: 2, lineHeight: 1.2,
                            whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis",
                          }}>{course.name}</div>
                          <div style={{
                            fontSize: 13, color: colors.textLight,
                            display: "flex", alignItems: "center", gap: 4,
                          }}>
                            {course.city}, {course.state}
                            <span style={{ color: colors.tan }}>·</span>
                            Par {course.par}
                          </div>
                        </div>

                        <div style={{ display: "flex", alignItems: "center", gap: 10, flexShrink: 0 }}>
                          <TypePill type={course.type} />
                          <ChevronRight />
                        </div>
                      </div>
                    ))}
                  </div>
                </>
              ) : (
                <div style={{ padding: "48px 0", textAlign: "center" }}>
                  <div style={{ fontSize: 15, fontWeight: 500, color: colors.text, marginBottom: 4 }}>No courses found</div>
                  <div style={{ fontSize: 14, color: colors.textLight }}>Try a different search or add manually</div>
                </div>
              )}
            </div>
          )}

          {/* ===== EMPTY STATE ===== */}
          {!query && (
            <div style={{ padding: "0 20px" }}>

              {/* Recent searches */}
              {recentSearches.length > 0 && (
                <div style={{ marginBottom: 20 }}>
                  <div style={{
                    fontSize: 13, fontWeight: 600, letterSpacing: 0.5,
                    textTransform: "uppercase", color: colors.textLight, marginBottom: 10,
                  }}>
                    Recent
                  </div>
                  <div style={{ display: "flex", flexWrap: "wrap", gap: 8 }}>
                    {recentSearches.map((term, i) => (
                      <button
                        key={i}
                        onClick={() => { setQuery(term); inputRef.current?.focus(); }}
                        style={{
                          background: colors.white, border: `1.5px solid ${colors.tan}44`,
                          borderRadius: 10, padding: "8px 14px", cursor: "pointer",
                          fontSize: 15, fontFamily: font, fontWeight: 450, color: colors.text,
                          display: "flex", alignItems: "center", gap: 6,
                          transition: "all 0.15s ease",
                        }}
                        onMouseDown={e => e.currentTarget.style.transform = "scale(0.95)"}
                        onMouseUp={e => e.currentTarget.style.transform = "scale(1)"}
                        onMouseLeave={e => e.currentTarget.style.transform = "scale(1)"}
                      >
                        <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke={colors.tan} strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round">
                          <circle cx="12" cy="12" r="10" /><polyline points="12 6 12 12 16 14" />
                        </svg>
                        {term}
                      </button>
                    ))}
                  </div>
                </div>
              )}
              <div style={{ display: "flex", flexDirection: "column", gap: 10 }}>
                {[
                  {
                    icon: <LocationIcon />, title: "Nearby Courses",
                    desc: "Find courses close to your current location",
                    color: colors.sage,
                  },
                  {
                    icon: <EditIcon />, title: "Add Manually",
                    desc: "Enter course details yourself",
                    color: colors.warmGray,
                  },
                ].map((item, i) => (
                  <div
                    key={i}
                    style={{
                      background: colors.white, borderRadius: 14,
                      padding: "18px 16px", cursor: "pointer",
                      display: "flex", alignItems: "center", gap: 14,
                      border: `1.5px solid ${colors.tan}33`,
                      transition: "all 0.2s ease",
                    }}
                    onMouseDown={e => e.currentTarget.style.transform = "scale(0.98)"}
                    onMouseUp={e => e.currentTarget.style.transform = "scale(1)"}
                    onMouseLeave={e => e.currentTarget.style.transform = "scale(1)"}
                  >
                    <div style={{
                      width: 42, height: 42, borderRadius: 12,
                      background: `${item.color}18`,
                      display: "flex", alignItems: "center", justifyContent: "center",
                      color: item.color, flexShrink: 0,
                    }}>
                      {item.icon}
                    </div>
                    <div style={{ flex: 1 }}>
                      <div style={{ fontSize: 17, fontWeight: 500, color: colors.text }}>{item.title}</div>
                      <div style={{ fontSize: 13, color: colors.textLight, marginTop: 2 }}>{item.desc}</div>
                    </div>
                    <ChevronRight />
                  </div>
                ))}
              </div>


            </div>
          )}

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
