/**
 * NotificationsDropdown - Dropdown de notificaciones en el header
 */
'use client';

import { useRouter } from 'next/navigation';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';
import { Button } from '@/components/ui/button';
import { ScrollArea } from '@/components/ui/scroll-area';
import { Bell, AlertTriangle, Info, CheckCircle, XCircle, Calendar } from 'lucide-react';
import { cn } from '@/lib/utils';
import { useNotifications, type Notification } from '@/hooks/use-notifications';

const iconMap = {
  warning: AlertTriangle,
  info: Info,
  success: CheckCircle,
  error: XCircle,
};

const colorMap = {
  warning: 'text-amber-500',
  info: 'text-blue-500',
  success: 'text-emerald-500',
  error: 'text-red-500',
};

const bgMap = {
  warning: 'bg-amber-500/10',
  info: 'bg-blue-500/10',
  success: 'bg-emerald-500/10',
  error: 'bg-red-500/10',
};

export function NotificationsDropdown() {
  const router = useRouter();
  const { notifications, unreadCount, hasNotifications } = useNotifications();

  const handleClick = (notification: Notification) => {
    if (notification.href) {
      router.push(notification.href);
    }
  };

  return (
    <DropdownMenu>
      <DropdownMenuTrigger asChild>
        <Button variant="ghost" size="icon" className="relative">
          <Bell className="h-5 w-5" />
          {hasNotifications && (
            <span className="absolute -top-0.5 -right-0.5 h-4 w-4 rounded-full bg-destructive text-[10px] font-medium text-destructive-foreground flex items-center justify-center">
              {unreadCount > 9 ? '9+' : unreadCount}
            </span>
          )}
        </Button>
      </DropdownMenuTrigger>
      <DropdownMenuContent align="end" className="w-80">
        <DropdownMenuLabel className="flex items-center justify-between">
          <span>Notificaciones</span>
          {hasNotifications && (
            <span className="text-xs text-muted-foreground font-normal">
              {unreadCount} alertas
            </span>
          )}
        </DropdownMenuLabel>
        <DropdownMenuSeparator />
        
        {!hasNotifications ? (
          <div className="py-8 text-center">
            <Bell className="h-8 w-8 mx-auto text-muted-foreground/50 mb-2" />
            <p className="text-sm text-muted-foreground">No hay notificaciones</p>
            <p className="text-xs text-muted-foreground mt-1">
              Todo está al día
            </p>
          </div>
        ) : (
          <ScrollArea className="h-[300px]">
            {notifications.map((notification) => {
              const Icon = iconMap[notification.type];
              return (
                <DropdownMenuItem
                  key={notification.id}
                  className="flex items-start gap-3 p-3 cursor-pointer"
                  onClick={() => handleClick(notification)}
                >
                  <div className={cn('p-1.5 rounded-full shrink-0', bgMap[notification.type])}>
                    <Icon className={cn('h-4 w-4', colorMap[notification.type])} />
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className="text-sm font-medium">{notification.title}</p>
                    <p className="text-xs text-muted-foreground truncate">
                      {notification.description}
                    </p>
                  </div>
                </DropdownMenuItem>
              );
            })}
          </ScrollArea>
        )}
        
        <DropdownMenuSeparator />
        <DropdownMenuItem
          className="justify-center text-primary cursor-pointer"
          onClick={() => router.push('/calendar')}
        >
          <Calendar className="h-4 w-4 mr-2" />
          Ver calendario
        </DropdownMenuItem>
      </DropdownMenuContent>
    </DropdownMenu>
  );
}
