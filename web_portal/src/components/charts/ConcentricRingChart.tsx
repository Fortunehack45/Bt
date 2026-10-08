import React, { useState } from 'react';

interface RingData {
  label: string;
  percent: number;
  color: string;
  radius: number;
  strokeWidth: number;
}

interface ConcentricRingChartProps {
  activePercent?: number;
  streakPercent?: number;
  premiumPercent?: number;
}

export const ConcentricRingChart: React.FC<ConcentricRingChartProps> = ({
  activePercent = 75.6,
  streakPercent = 82.1,
  premiumPercent = 29.9,
}) => {
  const [hoveredIndex, setHoveredIndex] = useState<number | null>(null);

  const rings: RingData[] = [
    {
      label: 'Active Retention (7D)',
      percent: activePercent,
      color: '#00D084',
      radius: 96,
      strokeWidth: 14,
    },
    {
      label: '7-Day Habit Streaks',
      percent: streakPercent,
      color: '#38BDF8',
      radius: 74,
      strokeWidth: 14,
    },
    {
      label: 'Premium Paid Tier',
      percent: premiumPercent,
      color: '#F59E0B',
      radius: 52,
      strokeWidth: 14,
    },
  ];

  const center = 130;
  const size = 260;

  return (
    <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '36px', flexWrap: 'wrap' }}>
      <div style={{ position: 'relative', width: size, height: size }}>
        <svg
          viewBox={`0 0 ${size} ${size}`}
          width={size}
          height={size}
          style={{ transform: 'rotate(-90deg)', overflow: 'visible' }}
        >
          {rings.map((ring, idx) => {
            const circumference = 2 * Math.PI * ring.radius;
            const strokeDashoffset = circumference - (ring.percent / 100) * circumference;
            const isHovered = hoveredIndex === idx;

            return (
              <g
                key={idx}
                onMouseEnter={() => setHoveredIndex(idx)}
                onMouseLeave={() => setHoveredIndex(null)}
                style={{ cursor: 'pointer' }}
              >
                {/* Background track */}
                <circle
                  cx={center}
                  cy={center}
                  r={ring.radius}
                  fill="none"
                  stroke="rgba(255, 255, 255, 0.06)"
                  strokeWidth={ring.strokeWidth}
                />
                {/* Filled arc */}
                <circle
                  cx={center}
                  cy={center}
                  r={ring.radius}
                  fill="none"
                  stroke={ring.color}
                  strokeWidth={isHovered ? ring.strokeWidth + 3 : ring.strokeWidth}
                  strokeDasharray={circumference}
                  strokeDashoffset={strokeDashoffset}
                  strokeLinecap="round"
                  style={{
                    transition: 'all 0.5s cubic-bezier(0.4, 0, 0.2, 1)',
                    filter: isHovered ? `drop-shadow(0 0 10px ${ring.color})` : 'none',
                    opacity: hoveredIndex !== null && !isHovered ? 0.45 : 1,
                  }}
                />
              </g>
            );
          })}
        </svg>

        {/* Center Readout */}
        <div
          style={{
            position: 'absolute',
            top: 0,
            left: 0,
            width: '100%',
            height: '100%',
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
            justifyContent: 'center',
            pointerEvents: 'none',
          }}
        >
          <span style={{ fontSize: '0.72rem', color: '#9CA3AF', textTransform: 'uppercase', letterSpacing: '0.05em' }}>
            {hoveredIndex !== null ? rings[hoveredIndex].label : 'Platform Avg'}
          </span>
          <span style={{ fontSize: '1.45rem', fontWeight: 800, color: '#FFFFFF', letterSpacing: '-0.02em' }}>
            {hoveredIndex !== null
              ? `${rings[hoveredIndex].percent}%`
              : `${Math.round((activePercent + streakPercent + premiumPercent) / 3)}%`}
          </span>
        </div>
      </div>

      {/* Legend */}
      <div style={{ display: 'flex', flexDirection: 'column', gap: '14px', minWidth: '220px' }}>
        {rings.map((ring, idx) => (
          <div
            key={idx}
            onMouseEnter={() => setHoveredIndex(idx)}
            onMouseLeave={() => setHoveredIndex(null)}
            style={{
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'space-between',
              padding: '8px 12px',
              borderRadius: '10px',
              backgroundColor: hoveredIndex === idx ? 'rgba(255, 255, 255, 0.06)' : 'transparent',
              border: `1px solid ${hoveredIndex === idx ? ring.color : 'transparent'}`,
              cursor: 'pointer',
              transition: 'all 0.2s',
            }}
          >
            <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
              <div
                style={{
                  width: '10px',
                  height: '10px',
                  borderRadius: '50%',
                  backgroundColor: ring.color,
                  boxShadow: `0 0 8px ${ring.color}`,
                }}
              />
              <span style={{ fontSize: '0.85rem', color: '#D1D5DB', fontWeight: 600 }}>{ring.label}</span>
            </div>
            <strong style={{ fontSize: '0.9rem', color: '#FFFFFF' }}>{ring.percent}%</strong>
          </div>
        ))}
      </div>
    </div>
  );
};
