import React, { useState } from 'react';

const colors = {
  cream: '#FAF8F5',
  text: '#2C2C2C',
  textLight: '#6B6360',
  sage: '#7D9A78',
  tan: '#D4C4B0',
  coral: '#E8A598',
  warmGray: '#A0938A',
  white: '#FFFFFF',
};

const FlagIcon = ({ variant, color, size = 20 }) => {
  if (variant === 'filled') return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <path d="M5 4V21" stroke={color} strokeWidth="1.8" strokeLinecap="round" />
      <path d="M5 4C5 4 6.5 3 9.5 3C12.5 3 14 5 17 5C18.5 5 19.5 4.5 20 4V14C19.5 14.5 18.5 15 17 15C14 15 12.5 13 9.5 13C6.5 13 5 14 5 14"
        fill={color} fillOpacity="0.25" stroke={color} strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" />
    </svg>
  );
  if (variant === 'outlined') return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <path d="M5 4V21" stroke={color} strokeWidth="1.8" strokeLinecap="round" />
      <path d="M5 4C5 4 6.5 3 9.5 3C12.5 3 14 5 17 5C18.5 5 19.5 4.5 20 4V14C19.5 14.5 18.5 15 17 15C14 15 12.5 13 9.5 13C6.5 13 5 14 5 14"
        fill="none" stroke={color} strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" />
    </svg>
  );
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <path d="M5 4V21" stroke={color} strokeWidth="1.8" strokeLinecap="round" />
      <path d="M5 4C5 4 6.5 3 9.5 3C12.5 3 14 5 17 5C18.5 5 19.5 4.5 20 4V14C19.5 14.5 18.5 15 17 15C14 15 12.5 13 9.5 13C6.5 13 5 14 5 14"
        fill="none" stroke={color} strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" strokeDasharray="3 3" />
    </svg>
  );
};

const ChevronIcon = ({ color = colors.tan }) => (
  <svg width="16" height="16" viewBox="0 0 24 24" fill="none">
    <path d="M9 6L15 12L9 18" stroke={color} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" />
  </svg>
);

const course = {
  name: "Pebble Beach Golf Links",
  city: "Pebble Beach",
  state: "CA",
  courseType: "Public",
  holes: 18,
  rating: "loved",
  rank: 1,
  totalCourses: 8,
  notes: "Incredible ocean views on every hole. The par-3 7th is unforgettable. Worth every penny.",
  dateAdded: "Oct 15, 2024",
};

const ratingConfig = {
  loved: { color: colors.coral, label: 'Loved', flag: 'filled' },
  liked: { color: colors.sage, label: 'Liked', flag: 'outlined' },
  disliked: { color: colors.warmGray, label: "Didn't Love", flag: 'dashed' },
};

const CourseDetailScreen = () => {
  const { color, label, flag } = ratingConfig[course.rating];
  
  return (
    <div style={{
      backgroundColor: colors.cream,
      minHeight: '100%',
      fontFamily: '-apple-system, BlinkMacSystemFont, sans-serif',
      display: 'flex',
      flexDirection: 'column',
    }}>
      {/* Header */}
      <div style={{
        padding: '16px 20px',
        display: 'flex',
        justifyContent: 'space-between',
        alignItems: 'center',
        borderBottom: `1px solid ${colors.tan}40`,
      }}>
        <button style={{
          background: 'none',
          border: 'none',
          fontSize: '17px',
          color: colors.sage,
          cursor: 'pointer',
          padding: '4px 0',
          display: 'flex',
          alignItems: 'center',
          gap: '4px',
        }}>
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none">
            <path d="M15 18L9 12L15 6" stroke={colors.sage} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" />
          </svg>
          Rankings
        </button>
        <button style={{
          background: 'none',
          border: 'none',
          fontSize: '17px',
          color: colors.sage,
          cursor: 'pointer',
          padding: '4px 0',
        }}>
          Edit
        </button>
      </div>

      {/* Content */}
      <div style={{
        flex: 1,
        padding: '24px 20px',
        overflowY: 'auto',
      }}>
        {/* Course name and location */}
        <div style={{ marginBottom: '24px' }}>
          <h1 style={{
            fontSize: '26px',
            fontWeight: '600',
            color: colors.text,
            margin: '0 0 6px 0',
            letterSpacing: '-0.3px',
            lineHeight: 1.2,
          }}>
            {course.name}
          </h1>
          <p style={{
            fontSize: '17px',
            color: colors.textLight,
            margin: 0,
          }}>
            {course.city}, {course.state}
          </p>
        </div>

        {/* Rank and rating cards */}
        <div style={{
          display: 'flex',
          gap: '12px',
          marginBottom: '28px',
        }}>
          {/* Rank card */}
          <div style={{
            flex: 1,
            backgroundColor: colors.white,
            border: `1.5px solid ${colors.tan}`,
            borderRadius: '12px',
            padding: '16px',
            textAlign: 'center',
          }}>
            <div style={{
              fontSize: '13px',
              fontWeight: '600',
              color: colors.textLight,
              textTransform: 'uppercase',
              letterSpacing: '0.3px',
              marginBottom: '6px',
            }}>
              Rank
            </div>
            <div style={{
              fontSize: '32px',
              fontWeight: '600',
              color: colors.text,
            }}>
              #{course.rank}
            </div>
            <div style={{
              fontSize: '14px',
              color: colors.textLight,
            }}>
              of {course.totalCourses} courses
            </div>
          </div>

          {/* Rating card */}
          <div style={{
            flex: 1,
            backgroundColor: `${color}12`,
            border: `1.5px solid ${color}`,
            borderRadius: '12px',
            padding: '16px',
            textAlign: 'center',
          }}>
            <div style={{
              fontSize: '13px',
              fontWeight: '600',
              color: colors.textLight,
              textTransform: 'uppercase',
              letterSpacing: '0.3px',
              marginBottom: '8px',
            }}>
              Rating
            </div>
            <div style={{
              display: 'flex',
              justifyContent: 'center',
              marginBottom: '6px',
            }}>
              <FlagIcon variant={flag} color={color} size={32} />
            </div>
            <div style={{
              fontSize: '15px',
              fontWeight: '500',
              color: color,
            }}>
              {label}
            </div>
          </div>
        </div>

        {/* Course details */}
        <div style={{
          backgroundColor: colors.white,
          border: `1.5px solid ${colors.tan}`,
          borderRadius: '12px',
          marginBottom: '20px',
          overflow: 'hidden',
        }}>
          <div style={{
            display: 'flex',
            justifyContent: 'space-between',
            alignItems: 'center',
            padding: '14px 16px',
            borderBottom: `1px solid ${colors.tan}40`,
          }}>
            <span style={{ fontSize: '16px', color: colors.textLight }}>Type</span>
            <span style={{ fontSize: '16px', color: colors.text, fontWeight: '500' }}>{course.courseType}</span>
          </div>
          <div style={{
            display: 'flex',
            justifyContent: 'space-between',
            alignItems: 'center',
            padding: '14px 16px',
            borderBottom: `1px solid ${colors.tan}40`,
          }}>
            <span style={{ fontSize: '16px', color: colors.textLight }}>Holes</span>
            <span style={{ fontSize: '16px', color: colors.text, fontWeight: '500' }}>{course.holes}</span>
          </div>
          <div style={{
            display: 'flex',
            justifyContent: 'space-between',
            alignItems: 'center',
            padding: '14px 16px',
          }}>
            <span style={{ fontSize: '16px', color: colors.textLight }}>Added</span>
            <span style={{ fontSize: '16px', color: colors.text, fontWeight: '500' }}>{course.dateAdded}</span>
          </div>
        </div>

        {/* Notes section */}
        {course.notes && (
          <div style={{ marginBottom: '20px' }}>
            <div style={{
              fontSize: '13px',
              fontWeight: '600',
              color: colors.textLight,
              textTransform: 'uppercase',
              letterSpacing: '0.3px',
              marginBottom: '10px',
            }}>
              Notes
            </div>
            <div style={{
              backgroundColor: colors.white,
              border: `1.5px solid ${colors.tan}`,
              borderRadius: '12px',
              padding: '14px 16px',
            }}>
              <p style={{
                fontSize: '16px',
                color: colors.text,
                margin: 0,
                lineHeight: 1.5,
              }}>
                {course.notes}
              </p>
            </div>
          </div>
        )}

        {/* Actions */}
        <div style={{
          backgroundColor: colors.white,
          border: `1.5px solid ${colors.tan}`,
          borderRadius: '12px',
          overflow: 'hidden',
        }}>
          <button style={{
            width: '100%',
            display: 'flex',
            justifyContent: 'space-between',
            alignItems: 'center',
            padding: '14px 16px',
            border: 'none',
            borderBottom: `1px solid ${colors.tan}40`,
            backgroundColor: 'transparent',
            cursor: 'pointer',
            textAlign: 'left',
          }}>
            <span style={{ fontSize: '16px', color: colors.text }}>Change rating</span>
            <ChevronIcon />
          </button>
          <button style={{
            width: '100%',
            display: 'flex',
            justifyContent: 'space-between',
            alignItems: 'center',
            padding: '14px 16px',
            border: 'none',
            backgroundColor: 'transparent',
            cursor: 'pointer',
            textAlign: 'left',
          }}>
            <span style={{ fontSize: '16px', color: colors.coral }}>Delete course</span>
            <span></span>
          </button>
        </div>
      </div>
    </div>
  );
};

export default function CourseDetailMockup() {
  return (
    <div style={{
      display: 'flex',
      flexDirection: 'column',
      height: '100vh',
      backgroundColor: '#E8E4E0',
      fontFamily: '-apple-system, BlinkMacSystemFont, sans-serif'
    }}>
      {/* Header */}
      <div style={{
        padding: '16px 24px',
        backgroundColor: '#fff',
        borderBottom: '1px solid #ddd'
      }}>
        <h2 style={{ margin: 0, fontSize: '16px', color: colors.text }}>
          Front Nine — Course Detail
        </h2>
        <p style={{ margin: '4px 0 0 0', fontSize: '13px', color: colors.textLight }}>
          View a ranked course's details and actions
        </p>
      </div>

      {/* Phone frame */}
      <div style={{
        flex: 1,
        display: 'flex',
        justifyContent: 'center',
        alignItems: 'center',
        padding: '20px'
      }}>
        <div style={{
          width: '375px',
          height: '720px',
          borderRadius: '40px',
          overflow: 'hidden',
          boxShadow: '0 25px 50px rgba(0,0,0,0.15)',
          border: '8px solid #1a1a1a',
          backgroundColor: colors.cream
        }}>
          {/* Dynamic Island */}
          <div style={{
            height: '47px',
            backgroundColor: colors.cream,
            display: 'flex',
            justifyContent: 'center',
            alignItems: 'flex-end',
            paddingBottom: '8px'
          }}>
            <div style={{
              width: '120px',
              height: '28px',
              backgroundColor: '#1a1a1a',
              borderRadius: '20px'
            }} />
          </div>

          {/* Screen content */}
          <div style={{
            height: 'calc(100% - 47px)',
            overflow: 'hidden',
            display: 'flex',
            flexDirection: 'column'
          }}>
            <CourseDetailScreen />
          </div>
        </div>
      </div>

      {/* Design notes */}
      <div style={{
        padding: '16px 24px',
        backgroundColor: '#fff',
        borderTop: '1px solid #ddd'
      }}>
        <p style={{ margin: 0, fontSize: '13px', color: colors.textLight }}>
          <strong style={{ color: colors.text }}>Actions:</strong> "Edit" in header for details, "Change rating" triggers comparison flow if tier changes, "Delete" with confirmation.
        </p>
      </div>
    </div>
  );
}
