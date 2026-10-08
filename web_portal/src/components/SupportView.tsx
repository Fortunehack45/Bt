import React, { useState } from 'react';
import { Send, CheckCircle2, Clock, AlertCircle, ShieldAlert } from 'lucide-react';
import { SupportTicket, TicketStatus } from '../types';
import { INITIAL_TICKETS } from '../services/data';

export const SupportView: React.FC = () => {
  const [tickets, setTickets] = useState<SupportTicket[]>(INITIAL_TICKETS);
  const [activeTicketId, setActiveTicketId] = useState<string>(tickets[0].id);
  const [filter, setFilter] = useState<TicketStatus | 'all'>('all');
  const [replyText, setReplyText] = useState('');

  const activeTicket = tickets.find(t => t.id === activeTicketId) || tickets[0];

  const filteredTickets = tickets.filter(t => (filter === 'all' ? true : t.status === filter));

  const handleSendReply = (e: React.FormEvent) => {
    e.preventDefault();
    if (!replyText.trim()) return;

    const newMessage = {
      id: `msg-${Date.now()}`,
      sender: 'support' as const,
      senderName: 'Support Agent Marcus',
      text: replyText.trim(),
      timestamp: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
    };

    setTickets(prev =>
      prev.map(t => {
        if (t.id === activeTicket.id) {
          return {
            ...t,
            status: t.status === 'open' ? 'in_progress' : t.status,
            messages: [...t.messages, newMessage],
            updatedAt: new Date().toISOString(),
          };
        }
        return t;
      })
    );

    setReplyText('');
  };

  const handleQuickTemplate = (template: string) => {
    setReplyText(template);
  };

  const getStatusBadge = (status: TicketStatus) => {
    switch (status) {
      case 'open':
        return (
          <span style={{ display: 'inline-flex', alignItems: 'center', gap: '4px', color: '#00D084', backgroundColor: 'rgba(0, 208, 132, 0.12)', border: '1px solid rgba(0, 208, 132, 0.3)', padding: '2px 8px', borderRadius: '999px', fontSize: '0.7rem', fontWeight: 700, textTransform: 'uppercase' }}>
            <AlertCircle size={10} /> Open
          </span>
        );
      case 'in_progress':
        return (
          <span style={{ display: 'inline-flex', alignItems: 'center', gap: '4px', color: '#F59E0B', backgroundColor: 'rgba(245, 158, 11, 0.12)', border: '1px solid rgba(245, 158, 11, 0.3)', padding: '2px 8px', borderRadius: '999px', fontSize: '0.7rem', fontWeight: 700, textTransform: 'uppercase' }}>
            <Clock size={10} /> In Progress
          </span>
        );
      case 'resolved':
        return (
          <span style={{ display: 'inline-flex', alignItems: 'center', gap: '4px', color: '#9CA3AF', backgroundColor: 'rgba(255, 255, 255, 0.05)', border: '1px solid rgba(255, 255, 255, 0.1)', padding: '2px 8px', borderRadius: '999px', fontSize: '0.7rem', fontWeight: 700, textTransform: 'uppercase' }}>
            <CheckCircle2 size={10} /> Resolved
          </span>
        );
    }
  };

  return (
    <div className="tab-enter" style={{ display: 'grid', gridTemplateColumns: '360px 1fr', gap: '24px', minHeight: '660px' }}>
      {/* Sidebar: Inquiry Ticket Queue */}
      <div className="glass-card" style={{ display: 'flex', flexDirection: 'column', height: '660px' }}>
        <div style={{ marginBottom: '16px' }}>
          <h3 style={{ fontSize: '1.15rem', fontWeight: 700, color: '#FFFFFF', margin: 0 }}>
            Inquiry Inbox
          </h3>
          <p style={{ fontSize: '0.8rem', color: '#9CA3AF', margin: '4px 0 0 0' }}>
            Live triage for mobile app support tickets
          </p>
        </div>

        {/* Filter Pills */}
        <div style={{ display: 'flex', gap: '6px', marginBottom: '14px', flexWrap: 'wrap' }}>
          {(['all', 'open', 'in_progress', 'resolved'] as const).map(f => (
            <button
              key={f}
              onClick={() => setFilter(f)}
              style={{
                backgroundColor: filter === f ? 'rgba(0, 208, 132, 0.18)' : 'rgba(255, 255, 255, 0.04)',
                border: `1px solid ${filter === f ? 'rgba(0, 208, 132, 0.4)' : 'rgba(255, 255, 255, 0.08)'}`,
                color: filter === f ? '#00D084' : '#9CA3AF',
                fontFamily: 'inherit',
                fontSize: '0.75rem',
                fontWeight: 600,
                padding: '4px 10px',
                borderRadius: '999px',
                cursor: 'pointer',
                textTransform: 'capitalize',
                transition: 'all 0.15s ease',
              }}
            >
              {f.replace('_', ' ')}
            </button>
          ))}
        </div>

        {/* Tickets Scroll List */}
        <div style={{ flex: 1, overflowY: 'auto', display: 'flex', flexDirection: 'column', gap: '8px', paddingRight: '4px' }}>
          {filteredTickets.map(ticket => {
            const isSelected = ticket.id === activeTicket.id;
            const lastMsg = ticket.messages[ticket.messages.length - 1];

            return (
              <div
                key={ticket.id}
                onClick={() => setActiveTicketId(ticket.id)}
                style={{
                  backgroundColor: isSelected ? 'rgba(0, 208, 132, 0.09)' : 'rgba(255, 255, 255, 0.03)',
                  border: `1px solid ${isSelected ? 'rgba(0, 208, 132, 0.4)' : 'rgba(255, 255, 255, 0.06)'}`,
                  borderRadius: '12px',
                  padding: '12px 14px',
                  cursor: 'pointer',
                  transition: 'all 0.15s ease',
                }}
              >
                <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '4px' }}>
                  <span style={{ fontSize: '0.72rem', fontFamily: 'monospace', fontWeight: 700, color: '#00D084' }}>
                    {ticket.userAccount.accountIdentifier}
                  </span>
                  {getStatusBadge(ticket.status)}
                </div>

                <div style={{ fontSize: '0.85rem', fontWeight: 600, color: '#FFFFFF', marginBottom: '4px', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
                  {ticket.subject}
                </div>

                <div style={{ fontSize: '0.76rem', color: '#6B7280', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap', marginBottom: '6px' }}>
                  {lastMsg?.text || 'No messages yet'}
                </div>

                <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', fontSize: '0.7rem', color: '#9CA3AF' }}>
                  <span>{ticket.category}</span>
                  <span>{new Date(ticket.updatedAt).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}</span>
                </div>
              </div>
            );
          })}
        </div>
      </div>

      {/* Main Console: Live Chat & Account Metadata Inspector */}
      <div className="glass-card" style={{ display: 'flex', flexDirection: 'column', height: '660px', padding: '24px' }}>
        {/* Header */}
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', paddingBottom: '14px', borderBottom: '1px solid rgba(255, 255, 255, 0.08)' }}>
          <div>
            <h4 style={{ fontSize: '1.1rem', fontWeight: 700, color: '#FFFFFF', margin: 0 }}>
              {activeTicket.subject}
            </h4>
            <div style={{ fontSize: '0.78rem', color: '#9CA3AF', marginTop: '2px' }}>
              Ticket {activeTicket.id} • Category: {activeTicket.category}
            </div>
          </div>
          <div>{getStatusBadge(activeTicket.status)}</div>
        </div>

        {/* User Account Metadata Bar (Safe Non-Private Health Information) */}
        <div
          style={{
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
            backgroundColor: 'rgba(0, 0, 0, 0.3)',
            borderRadius: '10px',
            padding: '10px 16px',
            margin: '14px 0',
            fontSize: '0.78rem',
            flexWrap: 'wrap',
            gap: '12px',
          }}
        >
          <div style={{ display: 'flex', gap: '18px' }}>
            <div>
              <span style={{ color: '#6B7280' }}>User ID: </span>
              <strong style={{ color: '#FFFFFF', fontFamily: 'monospace' }}>{activeTicket.userAccount.accountIdentifier}</strong>
            </div>
            <div>
              <span style={{ color: '#6B7280' }}>Plan: </span>
              <strong style={{ color: activeTicket.userAccount.plan === 'premium' ? '#F59E0B' : '#9CA3AF', textTransform: 'uppercase' }}>
                {activeTicket.userAccount.plan}
              </strong>
            </div>
            <div>
              <span style={{ color: '#6B7280' }}>Platform: </span>
              <strong style={{ color: '#FFFFFF', textTransform: 'capitalize' }}>
                {activeTicket.userAccount.platform} ({activeTicket.userAccount.appBuild})
              </strong>
            </div>
          </div>

          <div style={{ display: 'flex', alignItems: 'center', gap: '6px', color: '#34D399', fontSize: '0.72rem' }}>
            <ShieldAlert size={12} />
            <span>Health telemetry isolated from support</span>
          </div>
        </div>

        {/* Message Thread Scroll Area */}
        <div
          style={{
            flex: 1,
            overflowY: 'auto',
            padding: '14px 6px',
            display: 'flex',
            flexDirection: 'column',
            gap: '12px',
          }}
        >
          {activeTicket.messages.map(msg => {
            const isSupport = msg.sender === 'support';
            return (
              <div
                key={msg.id}
                style={{
                  alignSelf: isSupport ? 'flex-end' : 'flex-start',
                  maxWidth: '75%',
                  backgroundColor: isSupport
                    ? 'linear-gradient(135deg, rgba(0, 208, 132, 0.25) 0%, rgba(5, 150, 105, 0.35) 100%)'
                    : 'rgba(255, 255, 255, 0.06)',
                  background: isSupport
                    ? 'linear-gradient(135deg, rgba(0, 208, 132, 0.28) 0%, rgba(5, 150, 105, 0.38) 100%)'
                    : 'rgba(255, 255, 255, 0.05)',
                  border: `1px solid ${isSupport ? 'rgba(0, 208, 132, 0.45)' : 'rgba(255, 255, 255, 0.08)'}`,
                  borderRadius: '16px',
                  borderBottomRightRadius: isSupport ? '4px' : '16px',
                  borderBottomLeftRadius: isSupport ? '16px' : '4px',
                  padding: '10px 16px',
                  color: '#FFFFFF',
                }}
              >
                <div style={{ fontSize: '0.68rem', fontWeight: 700, opacity: 0.7, marginBottom: '2px', color: isSupport ? '#00D084' : '#9CA3AF' }}>
                  {msg.senderName}
                </div>
                <div style={{ fontSize: '0.88rem', lineHeight: 1.45 }}>{msg.text}</div>
                <div style={{ fontSize: '0.65rem', opacity: 0.6, marginTop: '4px', textAlign: 'right' }}>
                  {msg.timestamp}
                </div>
              </div>
            );
          })}
        </div>

        {/* Quick Response Templates */}
        <div style={{ display: 'flex', gap: '8px', overflowX: 'auto', padding: '6px 0', marginBottom: '8px' }}>
          {[
            'Foreground step counter service is enabled',
            'Biometrics are protected in local keystore',
            'Shared partner challenge link is active',
          ].map((quick, idx) => (
            <button
              key={idx}
              onClick={() => handleQuickTemplate(quick)}
              style={{
                backgroundColor: 'rgba(255, 255, 255, 0.04)',
                border: '1px solid rgba(255, 255, 255, 0.08)',
                color: '#9CA3AF',
                fontSize: '0.72rem',
                padding: '4px 10px',
                borderRadius: '999px',
                cursor: 'pointer',
                whiteSpace: 'nowrap',
                transition: 'all 0.15s',
              }}
              onMouseEnter={e => {
                e.currentTarget.style.borderColor = '#00D084';
                e.currentTarget.style.color = '#FFFFFF';
              }}
              onMouseLeave={e => {
                e.currentTarget.style.borderColor = 'rgba(255, 255, 255, 0.08)';
                e.currentTarget.style.color = '#9CA3AF';
              }}
            >
              + {quick}
            </button>
          ))}
        </div>

        {/* Reply Form */}
        <form onSubmit={handleSendReply} style={{ display: 'flex', gap: '10px' }}>
          <input
            type="text"
            placeholder="Type answer to user or patient..."
            value={replyText}
            onChange={e => setReplyText(e.target.value)}
            style={{
              flex: 1,
              backgroundColor: 'rgba(0, 0, 0, 0.4)',
              border: '1px solid rgba(255, 255, 255, 0.1)',
              color: '#FFFFFF',
              fontFamily: 'inherit',
              fontSize: '0.88rem',
              padding: '12px 18px',
              borderRadius: '12px',
              outline: 'none',
            }}
          />
          <button
            type="submit"
            style={{
              background: 'linear-gradient(135deg, #00D084 0%, #059669 100%)',
              border: 'none',
              color: '#070D09',
              fontFamily: 'inherit',
              fontSize: '0.88rem',
              fontWeight: 700,
              padding: '0 20px',
              borderRadius: '12px',
              cursor: 'pointer',
              display: 'flex',
              alignItems: 'center',
              gap: '8px',
              boxShadow: '0 0 20px rgba(0, 208, 132, 0.25)',
            }}
          >
            <Send size={16} />
            Send Answer
          </button>
        </form>
      </div>
    </div>
  );
};
