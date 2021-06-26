import { AutenticacaoDTO } from '@admin/domain';
import { AuthService, LocalAuthGuard } from '@admin/services';
import { Controller, Post, Req, UseGuards } from '@nestjs/common';

@Controller()
export class AuthController {

  constructor(
    private readonly authService: AuthService
  ) { }

  @UseGuards(LocalAuthGuard)
  @Post('/auth')
  async login(@Req() req: any): Promise<AutenticacaoDTO> {
    return await this.authService.login(req.user);
  }
}
