import React, { useState } from 'react';
import { RadarMetric } from '../../types';

interface PolygonRadarChartProps {
  data: RadarMetric[];
  size?: number;
}

export const PolygonRadarChart: React.FC<PolygonRadarChartProps> = ({
  data,
  size = 280,
}) => {
  const [activeAxis, setActiveAxis] = useState<number | null>(null);

  const center = size / 2;
  const radius = size * 0.38;
  const totalAxes = data.length;
  const angleStep = (Math.PI * 2) / totalAxes;

  // Concentric levels (0.2, 0.4, 0.6, 0.8, 1.0)
  const levels = [0.2, 0.4, 0.6, 0.8, 1.0];

  const getCoordinates = (index: number, valueFactor: number) => {
    const angle = index * angleStep - Math.PI / 2; // Start from top (12 o'clock)
    const x = center + radius * valueFactor * Math.cos(angle);
    const y = center + radius * valueFactor * Math.sin(angle);
    return { x, y };
  };

  // Generate data polygon points
  const dataPoints = data.map((d, i) => getCoordinates(i, d.value / 100));
  const dataPolygonString = dataPoints.map(p => `${p.x},${p.y}`).join(' ');

  return (
    <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '32px', flexWrap: 'wrap' }}>
      <div style={{ position: 'relative', width: size, height: size }}>
        <svg viewBox={`0 0 ${size} ${size}`} width={size} height={size}>
          <defs>
            <radialGradient id="radarFillGrad" cx="50%" cy="50%" r="50%">
              <stop offset="0%" stopColor="#00D084" stopOpacity="0.38" />
              <stop offset="100%" stopColor="#059669" stopOpacity="0.12" />
            </radialGradient>
          </defs>

          {/* Concentric grid polygons */}
          {levels.map((lvl, lIdx) => {
            const gridPoints = Array.from({ length: totalAxes }).map((_, i) =>
              getCoordinates(i, lvl)
            );
            const gridString = gridPoints.map(p => `${p.x},${p.y}`).join(' ');
            return (
              <polygon
                key={lIdx}
                points={gridString}
                fill="none"
                stroke="rgba(255, 255, 255, 0.08)"
                strokeWidth={1}
              />
            );
          })}

          {/* Radial axis lines */}
          {data.map((_, i) => {
            const target = getCoordinates(i, 1.0);
            return (
              <line
                key={i}
                x1={center}
                y1={center}
                x2={target.x}
                y2={target.y}
                stroke="rgba(255, 255, 255, 0.1)"
                strokeWidth={1}
                strokeDasharray="2 2"
              />
            );
          })}

          {/* Main filled data polygon */}
          <polygon
            points={dataPolygonString}
            fill="url(#radarFillGrad)"
            stroke="#00D084"
            strokeWidth={2.4}
            style={{
              filter: 'drop-shadow(0 0 12px rgba(0, 208, 132, 0.45))',
              transition: 'all 0.3s ease',
            }}
          />

          {/* Data point dots and text labels */}
          {data.map((d, i) => {
            const p = dataPoints[i];
            const labelCoord = getCoordinates(i, 1.18);
            const isHovered = activeAxis === i;

            return (
              <g
                key={i}
                onMouseEnter={() => setActiveAxis(i)}
                onMouseLeave={() => setActiveAxis(null)}
                style={{ cursor: 'pointer' }}
              >
                {/* Outer halo */}
                {isHovered && (
                  <circle
                    cx={p.x}
                    cy={p.y}
                    r={9}
                    fill="none"
                    stroke="#00D084"
                    strokeWidth={1.5}
                    opacity={0.7}
                  />
                )}
                {/* Data Vertex */}
                <circle
                  cx={p.x}
                  cy={p.y}
                  r={isHovered ? 6 : 4.5}
                  fill="#FFFFFF"
                  stroke="#00D084"
                  strokeWidth={2}
                  style={{ transition: 'all 0.2s ease' }}
                />

                {/* Axis label text */}
                <text
                  x={labelCoord.x}
                  y={labelCoord.y}
                  textAnchor="middle"
                  dominantBaseline="central"
                  fontSize="10"
                  fontWeight={isHovered ? 700 : 600}
                  fill={isHovered ? '#00D084' : '#9CA3AF'}
                  style={{ transition: 'all 0.2s ease' }}
                >
                  {d.axis}
                </text>
              </g>
            );
          })}
        </svg>

        {/* Center Hover Value Callout */}
        {activeAxis !== null && (
          <div
            style={{
              position: 'absolute',
              top: '50%',
              left: '50%',
              transform: 'translate(-50%, -50%)',
              backgroundColor: 'rgba(7, 13, 9, 0.92)',
              border: '1px solid #00D084',
              borderRadius: '8px',
              padding: '4px 10px',
              pointerEvents: 'none',
              textAlign: 'center',
              boxShadow: '0 4px 14px rgba(0,0,0,0.5)',
            }}
          >
            <div style={{ fontSize: '0.7rem', color: '#9CA3AF' }}>{data[activeAxis].axis}</div>
            <div style={{ fontSize: '0.95rem', fontWeight: 800, color: '#00D084' }}>
              {data[activeAxis].value}%
            </div>
          </div>
        )}
      </div>

      {/* Axis Metric Badges */}
      <div style={{ display: 'flex', flexDirection: 'column', gap: '8px', minWidth: '200px' }}>
        {data.map((d, i) => {
          const isHovered = activeAxis === i;
          return (
            <div
              key={i}
              onMouseEnter={() => setActiveAxis(i)}
              onMouseLeave={() => setActiveAxis(null)}
              style={{
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'space-between',
                padding: '6px 12px',
                borderRadius: '8px',
                backgroundColor: isHovered ? 'rgba(0, 208, 132, 0.12)' : 'rgba(255, 255, 255, 0.03)',
                border: `1px solid ${isHovered ? 'rgba(0, 208, 132, 0.4)' : 'rgba(255, 255, 255, 0.06)'}`,
                cursor: 'pointer',
                transition: 'all 0.15s ease',
              }}
            >
              <span style={{ fontSize: '0.82rem', color: isHovered ? '#FFFFFF' : '#9CA3AF', fontWeight: 500 }}>
                {d.axis}
              </span>
              <strong style={{ fontSize: '0.85rem', color: '#00D084' }}>{d.value}%</strong>
            </div>
          );
        })}
      </div>
    </div>
  );
};
