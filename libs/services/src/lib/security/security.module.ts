import { Module } from '@nestjs/common';
import { SecurityService } from './security.service';

@Module({
  imports: [SecurityModule],
  providers: [SecurityService],
  exports: [SecurityService]
})
export class SecurityModule {}
