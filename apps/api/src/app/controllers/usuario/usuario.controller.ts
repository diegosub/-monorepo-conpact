import { Repository } from 'typeorm';
import { Usuario, UsuarioInputDto } from '@admin/domain';
import { JwtAuthGuard, UsuarioService } from '@admin/services';
import { Body, Controller, Get, Param, Post, UseGuards, UsePipes, ValidationPipe } from '@nestjs/common';

@Controller('usuario')
@UseGuards(JwtAuthGuard)
export class UsuarioController {

  constructor(
    private readonly usuarioService: UsuarioService
  ) { }

  @Get(':codigo')
  async get(@Param('codigo') codigo: number): Promise<Usuario> {
    return await this.usuarioService.getById(codigo);
  }

  // @Get()
  // async pesquisar(@Query('filtros') filtros: string): Promise<Usuario[]> {
  //   return await this.usuarioService.pesquisar(stringToFiltros(filtros));
  // }

  @Post()
  @UsePipes(new ValidationPipe({ transform: true }))
  async inserir(@Body() usuarioDto : UsuarioInputDto): Promise<Usuario> {

    console.log(usuarioDto);

    return null;
    //return await this.usuarioService.inserir(usuario);
  }

  // @Put(':id')
  // @UsePipes(new ValidationPipe())
  // async alterar(@Param('id') id: string, @Body() usuario: Usuario): Promise<Usuario> {
  //   return await this.usuarioService.alterar(id, usuario);
  // }
}
